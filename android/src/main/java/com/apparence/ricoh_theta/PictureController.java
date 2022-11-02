package com.apparence.ricoh_theta;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.Looper;

import com.theta360.sdk.v2.network.HttpConnector;
import com.theta360.sdk.v2.network.HttpEventListener;
import com.theta360.sdk.v2.view.MJpegInputStream;

import org.json.JSONException;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;
import java.util.concurrent.ExecutionException;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

// TODO: Abstract class to handle result & camera for Storage & Picture controllers
public class PictureController implements EventChannel.StreamHandler {
    // Flutter stuff
    private EventChannel.EventSink previewStreamSink;
    private MethodChannel.Result result;

    // Async tasks
    private ShowLiveViewTask livePreviewTask = null;

    private Timer previewTimer;
    private float currentFps;
    private String ipAddress;
    private HttpConnector camera;

    public void startLiveView(float fps) {
            currentFps = 60;
            livePreviewTask = new ShowLiveViewTask();
            livePreviewTask.execute(ipAddress);
    }

    public void stopLiveView() {
        if (previewTimer != null) {
            previewTimer.cancel();
        }
        previewTimer = null;
        if (livePreviewTask != null) {
            livePreviewTask.cancel(true);
        }
    }

    public void resumeLiveView() {
        if (previewTimer != null) {
            previewTimer.cancel();
        }
        startLiveView(currentFps);
    }

    public void takePicture(final String path) {
        CaptureListener captureListener = new CaptureListener(path);

        camera.takePicture(captureListener);
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.previewStreamSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        if (this.previewStreamSink != null) {
            this.previewStreamSink.endOfStream();
        }
        this.previewStreamSink = null;
    }

    private class ShowLiveViewTask extends AsyncTask<String, String, MJpegInputStream> {

        @Override
        protected MJpegInputStream doInBackground(String... ipAddress) {
            MJpegInputStream mjis = null;
            final int MAX_RETRY_COUNT = 20;

            for (int retryCount = 0; retryCount < MAX_RETRY_COUNT; retryCount++) {
                try {
                    HttpConnector localCamera = camera;
                    if (localCamera == null) {
                        localCamera = new HttpConnector(ipAddress[0]);

                    }
                    InputStream is = localCamera.getLivePreview();
                    mjis = new MJpegInputStream(is);
                    retryCount = MAX_RETRY_COUNT;
                } catch (IOException e) {
                    try {
                        Thread.sleep(500);
                    } catch (InterruptedException e1) {
                        e1.printStackTrace();
                    }
                } catch (JSONException e) {
                    try {
                        Thread.sleep(500);
                    } catch (InterruptedException e1) {
                        e1.printStackTrace();
                    }
                }
            }

            return mjis;
        }

        @Override
        protected void onProgressUpdate(String... values) {
        }

        @Override
        protected void onPostExecute(MJpegInputStream mJpegInputStream) {
            previewTimer = new Timer();
            final Float period = (1 / currentFps) * 1000;
            Handler mainHandler = new Handler(Looper.getMainLooper());

            previewTimer.schedule(new TimerTask() {
                @Override
                public void run() {
                    final byte[] data;
                    try {
                        data = mJpegInputStream.readMJpegFrameBytes();

                        if (previewStreamSink != null) {
                            Runnable myRunnable = () -> previewStreamSink.success(data);
                            mainHandler.post(myRunnable);
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }, 0, period.longValue());
        }
    }

    private class CaptureListener implements HttpEventListener {
        private final String path;
        private String latestCapturedFileId;

        CaptureListener(final String path) {
            this.path = path;
        }

        @Override
        public void onCheckStatus(boolean newStatus) {

        }

        @Override
        public void onObjectChanged(String latestCapturedFileId) {
            this.latestCapturedFileId = latestCapturedFileId;
        }

        @Override
        public void onCompleted() {
            Bitmap thumbnail = camera.getThumb(latestCapturedFileId);
            final String fileName;
            if (thumbnail != null) {
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                thumbnail.compress(Bitmap.CompressFormat.JPEG, 100, baos);
                byte[] thumbnailImage = baos.toByteArray();

                UUID uuid = UUID.randomUUID();
                fileName = uuid.toString() + "_ricoh_thetha_preview.jpg";

                File file = new File(String.format("%s/%s", path, fileName));
                try (FileOutputStream fos = new FileOutputStream(file)) {
                    fos.write(thumbnailImage);
                } catch (IOException e) {
                    e.printStackTrace();
                    this.onError("error when writing file");
                }

                Map<String, String> resultData = new HashMap<>();
                resultData.put("fileName", fileName);
                resultData.put("fileId", latestCapturedFileId);
                result.success(resultData);
            }
        }

        @Override
        public void onError(String errorMessage) {
            result.error("PICTURE_TAKE_ERROR", errorMessage, "");
        }
    }

    // Setters

    public void setCurrentFps(float fps) {
        this.currentFps = fps;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public void setResult(MethodChannel.Result result) {
        this.result = result;
    }

    public void setCamera(HttpConnector camera) {
        this.camera = camera;
    }
}

