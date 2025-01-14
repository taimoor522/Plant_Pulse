import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:plantpulse/app_theme.dart';
import 'package:plantpulse/data/IoT/models/telemetry_data.dart';
import 'package:plantpulse/ui/IoT/IoT_monitoring_page.dart';
import 'package:plantpulse/ui/devices/cubit/devices_provider.dart';
import 'package:plantpulse/ui/devices/repository/devices_repository.dart';
import 'package:plantpulse/ui/farm/weather/weatherHome.dart';
import 'package:provider/provider.dart';

class FarmMenu extends StatefulWidget {
  @override
  _FarmMenuState createState() => _FarmMenuState();
}

class _FarmMenuState extends State<FarmMenu> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DevicesProvider>().loadDevices();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<DevicesProvider>().loadDevices();
        },
        color: Colors.black,
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            WeatherHome(),
            Consumer<DevicesProvider>(builder: (context, provider, _) {
              if (provider.loadingDevices) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 200),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ],
                );
              } else if (provider.devicesData?.isEmpty ?? true) {
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: Text('No Devices'),
                  ),
                );
              }
              final devicesDataFutures = provider.devicesData;
              final DevicesRepository _repository = DevicesRepository();
              // print('devices!.length ${devices!.length}');
              return ListView.separated(
                // padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                itemCount: devicesDataFutures!.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (_, i) => SizedBox(height: 10),
                itemBuilder: (_, index) {
                  return FutureBuilder(
                      future: devicesDataFutures[index],
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final record = snapshot.data?.data?.isNotEmpty ?? false
                              ? snapshot.data?.data?.first
                              : null;

                          if (record == null) {
                            return SizedBox.shrink();
                          }
                          return Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 24.w,
                                  right: 24.w,
                                  top: 10.h,
                                  bottom: 18.h,
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: getColorFromMoisture(record.moisture),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8.0),
                                          bottomLeft: Radius.circular(8.0),
                                          bottomRight: Radius.circular(8.0),
                                          topRight: Radius.circular(68.0),
                                        ),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                            color: AppTheme.appTheme.colorScheme.background
                                                .withOpacity(0.6),
                                            offset: Offset(1.1, 1.1),
                                            blurRadius: 10.0,
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        tileColor: Colors.transparent,
                                        onTap: () async {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => Provider(
                                                create: (context) => TelemetryData(
                                                    timestamp: DateTime.now(), value: '0'),
                                                child: IoTMonitoringPage(
                                                  hostname: record.hostName ?? '',
                                                  pageTitle: "IoT Monitoring",
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        title: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Sensor'.padRight(15) +
                                                  ' : ' +
                                                  (record.sensor ?? 0).toString(),
                                              textAlign: TextAlign.left,
                                              style: AppTheme.appTheme.textTheme.titleLarge!
                                                  .copyWith(color: Colors.white),
                                            ),
                                            Text(
                                              'Moisture'.padRight(14) +
                                                  ' : ' +
                                                  (record.moisture ?? 0).toString(),
                                              textAlign: TextAlign.left,
                                              style: AppTheme.appTheme.textTheme.titleLarge!
                                                  .copyWith(color: Colors.white),
                                            ),
                                            Text(
                                              'Location'.padRight(14) +
                                                  ' : ' +
                                                  (record.location ?? 0).toString(),
                                              textAlign: TextAlign.left,
                                              style: AppTheme.appTheme.textTheme.titleLarge!
                                                  .copyWith(color: Colors.white),
                                            ),
                                            Text(
                                              'Updated At'.padRight(12) +
                                                  ' : ' +
                                                  DateFormat("dd,MMM yyyy").format(
                                                    DateTime.parse(
                                                      record.updatedAt ?? DateTime.now().toString(),
                                                    ),
                                                  ),
                                              textAlign: TextAlign.left,
                                              style: AppTheme.appTheme.textTheme.titleLarge!
                                                  .copyWith(color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0.0,
                                right: 5.0,
                                height: 80,
                                // width: 80,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (record.moisture != null && record.moisture != 0)
                                      Image.asset(
                                        'assets/images/soil_moisture.png',
                                        width: 28, // Adjust the width as needed
                                        height: 28,
                                      ),
                                    if (record.temperature != null && record.temperature != 0)
                                      Image.asset(
                                        'assets/images/air_temperature.png',
                                        width: 28, // Adjust the width as needed
                                        height: 28,
                                      ),
                                    if (record.humidity != null && record.humidity != 0)
                                      Image.asset(
                                        'assets/images/air_humidity.png',
                                        width: 28, // Adjust the width as needed
                                        height: 28,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return SizedBox();
                        }
                      });
                },
              );
            })
            // GFListTile(
            //   avatar: GFAvatar(
            //     backgroundImage: AssetImage('assets/images/manage_planting.png'),
            //     backgroundColor: GFColors.TRANSPARENT,
            //   ),
            //   titleText: 'Planting',
            //   subTitle: Text('Store and view planting related activities.'),
            //   color: Color(kPastelGreen),
            //   icon: Icon(Icons.chevron_right),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       PageTransition(type: PageTransitionType.leftToRightWithFade, child: PlantingMenu()),
            //     );
            //   },
            // ),
            // GFListTile(
            //   avatar: GFAvatar(
            //     backgroundImage: AssetImage('assets/images/manage_harvest.png'),
            //     backgroundColor: GFColors.TRANSPARENT,
            //   ),
            //   titleText: 'Harvesting',
            //   color: Color(kBrownClr),
            //   subTitle: Text('Store and view planting related activities.'),
            //   icon: Icon(Icons.chevron_right),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       PageTransition(type: PageTransitionType.leftToRightWithFade, child: HarvestMenu()),
            //     );
            //   },
            // ),
            // GFListTile(
            //   avatar: GFAvatar(
            //     backgroundImage: AssetImage('assets/images/manage_news.png'),
            //     backgroundColor: GFColors.TRANSPARENT,
            //   ),
            //   titleText: 'View News',
            //   color: Colors.blueGrey[100],
            //   subTitle: Text('Store and view planting related activities.'),
            //   icon: Icon(Icons.chevron_right),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       PageTransition(type: PageTransitionType.leftToRightWithFade, child: HomePage()),
            //     );
            //   },
            // ),
            // GFListTile(
            //   avatar: GFAvatar(
            //     backgroundImage: AssetImage('assets/images/manage_statistics.png'),
            //     backgroundColor: GFColors.TRANSPARENT,
            //   ),
            //   titleText: 'View Statistics',
            //   subTitle: Text('Store and view planting related activities.'),
            //   color: Colors.teal[200],
            //   icon: Icon(Icons.chevron_right),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       PageTransition(
            //           type: PageTransitionType.leftToRightWithFade, child: StatisticsHome()),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  LinearGradient getColorFromMoisture(num? moisture) {
    if (moisture == null) {
      return LinearGradient(
        colors: [Colors.green, Colors.orangeAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (moisture > 70) {
      return LinearGradient(
        colors: [Color(0xFF006400), Color(0xFF1FDF39)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (moisture > 40) {
      return LinearGradient(
        colors: [Color(0xFF800000), Color(0xFFD2691E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return LinearGradient(
        colors: [Colors.yellow, Colors.orangeAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }
}
