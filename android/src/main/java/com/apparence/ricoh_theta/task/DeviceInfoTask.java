package com.apparence.ricoh_theta.task;


import android.os.AsyncTask;

import com.theta360.sdk.v2.network.DeviceInfo;
import com.theta360.sdk.v2.network.HttpConnector;

import org.json.JSONException;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class DeviceInfoTask extends AsyncTask<Void, Void, Map<String, String>> {

    final HttpConnector camera;
    final MethodChannel.Result result;

    public DeviceInfoTask(final HttpConnector camera, final MethodChannel.Result result) {
        this.camera = camera;
        this.result = result;
    }

    @Override
    protected Map<String, String> doInBackground(Void... voids) {
        try {
            DeviceInfo deviceInfo = camera.getDeviceInfo();
            Map<String, String> resultData = new HashMap<>();
            resultData.put("model", deviceInfo.getModel());
            resultData.put("firmwareVersion", deviceInfo.getDeviceVersion());
            resultData.put("serialNumber", deviceInfo.getSerialNumber());
            return resultData;
        } catch (IOException e) {
            // Nothing to do
        } catch (JSONException e) {
            // Nothing to do
        }


        return null;
    }


    @Override
    protected void onPostExecute(final Map<String, String> deviceInfo) {
        if (deviceInfo == null) {
            result.error("INFO_ERROR", "unable to retrieve device info", "");
            return;
        } else {
            result.success(deviceInfo);
            return;
        }
    }
}
