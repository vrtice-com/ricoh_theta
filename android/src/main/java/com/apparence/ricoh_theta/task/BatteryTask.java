package com.apparence.ricoh_theta.task;

import android.os.AsyncTask;

import com.theta360.sdk.v2.network.HttpConnector;

import org.json.JSONException;

import java.io.IOException;

import io.flutter.plugin.common.MethodChannel;

public class BatteryTask extends AsyncTask<Void, Void, Double> {

    final HttpConnector camera;
    final MethodChannel.Result result;


    public BatteryTask(final HttpConnector camera, final MethodChannel.Result result) {
        this.camera = camera;
        this.result = result;
    }

    @Override
    protected Double doInBackground(final Void... voids) {
        try {
            return camera.getBatteryLevel();
        } catch (JSONException e) {
            // Nothing to do
        } catch (IOException e) {
            // Nothing to do
        }

        return null;
    }

    @Override
    protected void onPostExecute(final Double batteryLevel) {
        if (batteryLevel == null) {
            result.error("BATTERY_ERROR", "unable to retrieve battery level", "");
        } else {
            result.success(batteryLevel);
        }
    }
}
