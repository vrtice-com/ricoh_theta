package com.apparence.ricoh_theta.task;

import android.os.AsyncTask;

import com.theta360.sdk.v2.network.HttpConnector;
import com.theta360.sdk.v2.network.StorageInfo;

import org.json.JSONException;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class StorageInfoTask extends AsyncTask<Void, Void, Map<String, Object>> {

    final HttpConnector camera;
    final MethodChannel.Result result;


    public StorageInfoTask(final HttpConnector camera, final MethodChannel.Result result) {
        this.camera = camera;
        this.result = result;
    }

    @Override
    protected Map<String, Object> doInBackground(final Void... voids) {
        try {
            StorageInfo storageInfo = camera.getStorageInfo();
            Map<String, Object> resultData = new HashMap<>();
            resultData.put("maxCapacity", storageInfo.getMaxCapacity());
            resultData.put("freeSpaceInBytes", storageInfo.getFreeSpaceInBytes());
            resultData.put("freeSpaceInImages", storageInfo.getFreeSpaceInImages());
            resultData.put("imageWidth", storageInfo.getWidth());
            resultData.put("imageHeight", storageInfo.getHeight());
            return resultData;
        } catch (JSONException e) {
            // Nothing to do
        } catch (IOException e) {
            // Nothing to do
        }

        return null;
    }

    @Override
    protected void onPostExecute(final Map<String, Object> storageInfo) {
        if (storageInfo == null) {
            result.error("STORAGE_INFO_ERROR", "unable to retrieve storage information", "");
        } else {
            result.success(storageInfo);
        }
    }
}
