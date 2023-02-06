package com.apparence.ricoh_theta;

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
import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;

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
    private Integer currentFps;
    private HttpConnector camera;

    public void startLiveView(Integer fps) {
        currentFps = 60;
        livePreviewTask = new ShowLiveViewTask();
        livePreviewTask.execute();
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

    public void takePicture(final String path, final MethodChannel.Result result) {
        CaptureListener captureListener = new CaptureListener(path, result);

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

    private class ShowLiveViewTask extends AsyncTask<Void, String, MJpegInputStream> {

        @Override
        protected MJpegInputStream doInBackground(Void... voids) {
            MJpegInputStream mjis = null;
            final int MAX_RETRY_COUNT = 20;

            for (int retryCount = 0; retryCount < MAX_RETRY_COUNT; retryCount++) {
                try {
                    InputStream is = camera.getLivePreview();
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
            final Float period = (1 / currentFps.floatValue()) * 1000;
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
        private final MethodChannel.Result captureResult;
        private String latestCapturedFileId;

        CaptureListener(final String path, final MethodChannel.Result captureResult) {
            this.path = path;
            this.captureResult = captureResult;
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
                captureResult.success(resultData);
                return;
            }
        }

        @Override
        public void onError(String errorMessage) {
            captureResult.error("PICTURE_TAKE_ERROR", errorMessage, "");
            return;
        }
    }

    // Setters

    public void setCurrentFps(Integer fps) {
        this.currentFps = fps;
    }

    public void setResult(MethodChannel.Result result) {
        this.result = result;
    }

    public void setCamera(HttpConnector camera) {
        this.camera = camera;
    }
}

