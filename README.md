<p align="center">
  <a href="https://pub.dev/packages/ricoh_theta"><img src="https://img.shields.io/pub/v/ricoh_theta" alt="pub dev ricoh_theta"></a>
</p>

## đ&nbsp; Overview

Use your **Ricoh Theta** device in your Flutter app very easily.

- đą Support both **iOS** and **Android**
- đĨ Direct **live preview**
- đ Adjust **FPS** for preview in realtime
- đ¸ Take a **picture** & show thumbnail
- đ Get device **battery level** 
- âšī¸ Fetch **device information**
- đ Retrieve device **files** from storage
- đ **View** photo in high resolution

## đ&nbsp; Installation

### Install the package
```sh
flutter pub add ricoh_theta
```

### Import the package
```dart
import 'package:ricoh_theta/ricoh_theta.dart';
```

## đ&nbsp; Get started

- Create an instance of the plugin
```dart
final _ricohThetaPlugin = RicohTheta();
```

- Init the connection to the camera by setting IP address of the device
```dart
await _ricohThetaPlugin.setTargetIp("192.168.1.1");
```

> Don't forget to connect your phone device to the [WiFi camera](https://support.theta360.com/es/catalog/easy_instructions.pdf) before any calls to the plugin.

## đ&nbsp; Available calls


| Param                | Type                                   | Description                                                                                 | Required |
|----------------------|----------------------------------------|---------------------------------------------------------------------------------------------|----------|
| setTargetIp          | ```Future```                           | set IP address to the camera & init connection (required before any calls)                  | â       |
| disconnect           | ```Future```                           | disconnect from the device                                                                  |          |
| startLiveView        | ```Future```                           | start capture of live view                                                                  |          |
| removeImageWithFileId | ```Future<bool?>```                   | remove an image from storage device                                                         |          |
| getImage             | ```Future<File?>```                    | get an image in high resolution from storage device                                         |          |
| pauseLiveView        | ```Future```                           | pause capture of live view                                                                  |          |
| stopLiveView         | ```Future```                           | stop capture of live view                                                                   |          |
| resumeLiveView       | ```Future```                           | resume capture of live view                                                                 |          |
| batteryLevel         | ```Future<num>```                      | get battery level in percent from device                                                    |          |
| getDeviceInfo        | ```Future<DeviceInfo?>```              | return the current device information like model, firmware & serial number                  |          |
| getStorageInfo       | ```Future<StorageInfo?>```             | return information about the device storage                                                 |          |
| update               | ```Future```                           | update device session, can be used to keep a session alive                                  |          |
| getImageInfoes       | ```Future<List<ImageInfoes>>```        | return information about images stored on the device                                        |          |
| takePicture          | ```Future<String?>```                  | take a picture & return a thumbnail path                                                    |          |
| listenCameraImages   | ```Stream<Uint8List>?```               | listen for live preview images coming from the device                                       |          |
| listenDownloadProgress  | ```Stream<num>?```                  | listen for download progress of images                                                      |          |
| adjustLiveViewFps    | ```Future```                           | adjust fraps per seconds for image preview                                                  |          |

> ```adjustLiveViewFps``` method is used to not surcharge the device, you can set 0 to skip this feature.

## đŖ&nbsp; Known projects using this package
### Spherik
[Spherik](https://spherik.com) is a mobile application allowing to gather 360 and standard media, and build awesome virtual tours on [the related web application](https://app.spherik.com).

<img src="https://github.com/vrtice-com/ricoh_theta/raw/main/.github/img/spherik_logo.png" alt="logo vrtice" height="30px">

## đŖ&nbsp; Sponsor

Initiated and sponsored by [vrtice](https://vrtice.com) with the help of the awesome team [Apparence.io](https://apparence.io).

<img src="https://github.com/vrtice-com/ricoh_theta/raw/main/.github/img/vrtice_logo.png" alt="logo vrtice" height="60px">
<br>
<br>
<img src="https://github.com/vrtice-com/ricoh_theta/raw/main/.github/img/apparence_logo.png" alt="logo apparence" height="30px">

## đĨ&nbsp; Contribution

Contributions are welcome.
Contribute by creating a PR or create an issue đ.