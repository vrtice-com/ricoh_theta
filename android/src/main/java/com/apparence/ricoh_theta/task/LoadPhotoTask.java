package com.apparence.ricoh_theta.task;

import android.annotation.SuppressLint;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.util.Log;

import com.theta360.sdk.v2.network.HttpConnector;
import com.theta360.sdk.v2.network.HttpDownloadListener;
import com.theta360.sdk.v2.network.ImageData;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class LoadPhotoTask extends AsyncTask<Void, Object, ImageData> {

    private HttpConnector camera;
    private String fileId;
    private String path;
    private MethodChannel.Result result;
    private long fileSize;
    private long receivedDataSize = 0;
    EventChannel.EventSink downloadStreamSink;

    public LoadPhotoTask(final HttpConnector camera, final String fileId, final String path, final MethodChannel.Result result) {
        this.camera = camera;
        this.fileId = fileId;
        this.path = path;
        this.result = result;
    }

    public void dispose() {
        if (this.downloadStreamSink != null) {
            this.downloadStreamSink.endOfStream();
            this.downloadStreamSink = null;
        }
    }

    @Override
    protected void onPreExecute() {
    }

    @Override
    protected ImageData doInBackground(Void... params) {
        try {
            ImageData resizedImageData = camera.getImage(fileId, new HttpDownloadListener() {
                @Override
                public void onTotalSize(long totalSize) {
                    fileSize = totalSize;
                }

                @Override
                public void onDataReceived(int size) {
                    receivedDataSize += size;

                    if (fileSize != 0) {
                        Double progressPercentage = ((double) receivedDataSize / fileSize);
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
            if (param instanceof Double) {
                if (downloadStreamSink != null) {
                    downloadStreamSink.success(param);
                }
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

            if (__bitmap != null) {
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                __bitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
                byte[] thumbnailImage = baos.toByteArray();

                UUID uuid = UUID.randomUUID();
                final String fileName = String.format("%s_ricoh_thetha_image.jpg", uuid.toString());

                File file = new File(String.format("%s/%s", path, fileName));
                try {
                    FileOutputStream fos = new FileOutputStream(file);
                    fos.write(thumbnailImage);
                    fos.close();
                } catch (IOException e) {
                    e.printStackTrace();
                    result.error("WRITE_FAILED", "unable to write file", "");
                    return;
                }

                Map<String, Object> image = new HashMap<>();
                image.put("fileName", fileName);
                image.put("width", (double) __bitmap.getWidth());
                image.put("height", (double) __bitmap.getHeight());
                image.put("size", file.length());

                result.success(image);
                return;
            }
        }
    }

    public void setDownloadStreamSink(EventChannel.EventSink downloadStreamSink) {
        this.downloadStreamSink = downloadStreamSink;
    }
}