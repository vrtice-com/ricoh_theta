package com.apparence.ricoh_theta;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.util.Log;

import com.theta360.sdk.v2.network.HttpConnector;
import com.theta360.sdk.v2.network.HttpDownloadListener;
import com.theta360.sdk.v2.network.HttpEventListener;
import com.theta360.sdk.v2.network.ImageData;
import com.theta360.sdk.v2.network.ImageInfo;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

// TODO: Abstract class to handle result & camera for Storage & Picture controllers
public class StorageController implements EventChannel.StreamHandler {
    // Flutter stuff
    private MethodChannel.Result result;
    private EventChannel.EventSink downloadStreamSink;

    // Async tasks
    private LoadPhotoTask mLoadPhotoTask = null;

    private HttpConnector camera;
    private String ipAddress;

    public void getImageWithFileId(String fileId) {
        mLoadPhotoTask = new LoadPhotoTask(fileId);
        mLoadPhotoTask.execute();
    }

    public void removeImageWithFileId(String fileId) {
        DeleteEventListener deleteListener = new DeleteEventListener();
        camera.deleteFile(fileId, deleteListener);
    }

    public void getImageInfoes() {
        ArrayList<ImageInfo> objects = camera.getList();
        int objectSize = objects.size();

        ArrayList<Map<String, Object>> images = new ArrayList();
        for (int i = 0; i < objectSize; i++) {
            ImageInfo info = objects.get(i);

            final String captureDate = info.getCaptureDate();

            Map<String, Object> image = new HashMap<>();
            image.put("fileFormat", "CODE_" + info.getFileFormat()); // this enum is not the same as iOS :/
            image.put("fileSize", info.getFileSize());
            image.put("imagePixWidth", info.getWidth());
            image.put("imagePixHeight", info.getHeight());
            image.put("fileName", info.getFileName());
            image.put("captureDate", captureDate != null ? Timestamp.valueOf(captureDate) : null);
            image.put("fileId", info.getFileId());

            images.add(image);
        }

        result.success(images);
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.downloadStreamSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        this.downloadStreamSink.endOfStream();
        this.downloadStreamSink = null;
    }

    private class LoadPhotoTask extends AsyncTask<Void, Object, ImageData> {

        private String fileId;
        private long fileSize;
        private long receivedDataSize = 0;

        public LoadPhotoTask(String fileId) {
            this.fileId = fileId;
        }

        @Override
        protected void onPreExecute() {
        }

        @Override
        protected ImageData doInBackground(Void... params) {
            try {
                HttpConnector camera = new HttpConnector(ipAddress);
                ImageData resizedImageData = camera.getImage(fileId, new HttpDownloadListener() {
                    @Override
                    public void onTotalSize(long totalSize) {
                        fileSize = totalSize;
                    }

                    @Override
                    public void onDataReceived(int size) {
                        receivedDataSize += size;

                        if (fileSize != 0) {
                            int progressPercentage = (int) (receivedDataSize * 100 / fileSize);
                            publishProgress(progressPercentage);
                        }
                    }
                });

                return resizedImageData;

            } catch (Throwable throwable) {
                String errorLog = Log.getStackTraceString(throwable);
                publishProgress(errorLog);
                return null;
            }
        }

        @Override
        protected void onProgressUpdate(Object... values) {

            for (Object param : values) {
                if (param instanceof Integer) {
                    downloadStreamSink.success(((Integer) param).doubleValue() / 100);
                }
            }
        }

        @SuppressLint("WrongThread")
        @Override
        protected void onPostExecute(ImageData imageData) {
            if (imageData != null) {

                byte[] dataObject = imageData.getRawData();

                if (dataObject == null) {
                    return;
                }

                Bitmap __bitmap = BitmapFactory.decodeByteArray(dataObject, 0, dataObject.length);


                Double yaw = imageData.getYaw();
                Double pitch = imageData.getPitch();
                Double roll = imageData.getRoll();

                if (__bitmap != null) {
                    ByteArrayOutputStream baos = new ByteArrayOutputStream();
                    __bitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
                    byte[] thumbnailImage = baos.toByteArray();

                    UUID uuid = UUID.randomUUID();
                    File tempFile = null;
                    try {
                        tempFile = File.createTempFile(uuid.toString() + "_ricoh_thetha_image", ".jpg", null);
                        FileOutputStream fos = new FileOutputStream(tempFile);
                        fos.write(thumbnailImage);
                        fos.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                        result.error("WRITE_FAILED", "unable to write file", "");
                    }

                    result.success(tempFile.getPath());
                }
            }
        }
    }

    private class DeleteEventListener implements HttpEventListener {
        @Override
        public void onCheckStatus(boolean newStatus) {
        }

        @Override
        public void onObjectChanged(String latestCapturedFileId) {
        }

        @Override
        public void onCompleted() {
            result.success(null);
        }

        @Override
        public void onError(String errorMessage) {
            result.error("DELETE_FAILED", "error when deleting image", errorMessage.toString());
        }
    }

    // Setters

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
