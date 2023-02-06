package com.apparence.ricoh_theta;

import com.apparence.ricoh_theta.task.LoadPhotoTask;
import com.theta360.sdk.v2.network.HttpConnector;
import com.theta360.sdk.v2.network.HttpEventListener;
import com.theta360.sdk.v2.network.ImageInfo;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

// TODO: Abstract class to handle result & camera for Storage & Picture controllers
public class StorageController implements EventChannel.StreamHandler {
    // Flutter stuff
    private MethodChannel.Result result;
    private LoadPhotoTask loadPhotoTask;

    private HttpConnector camera;

    public void getImageWithFileId(String fileId, String path) {
        loadPhotoTask = new LoadPhotoTask(camera, fileId, path, result);
        loadPhotoTask.execute();
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
        return;
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        if (loadPhotoTask != null) {
            loadPhotoTask.setDownloadStreamSink(events);
        }
    }

    @Override
    public void onCancel(Object arguments) {
        if (loadPhotoTask != null) {
            loadPhotoTask.dispose();
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
            return;
        }

        @Override
        public void onError(String errorMessage) {
            result.error("DELETE_FAILED", "error when deleting image", errorMessage.toString());
            return;
        }
    }

    // Setters

    public void setResult(MethodChannel.Result result) {
        this.result = result;
    }

    public void setCamera(HttpConnector camera) {
        this.camera = camera;
    }
}
