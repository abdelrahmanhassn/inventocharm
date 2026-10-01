import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:inventocharm/services/pocketbase_client.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventocharm/components/app_bar/custom_app_bar.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/components/constants/helpers/helper_functions.dart';
import 'package:inventocharm/components/widgets/primary_header.dart';
import 'package:inventocharm/screens/sales/widgets/sales_item_card.dart';

class SalesHistory extends StatefulWidget {
  const SalesHistory({Key? key}) : super(key: key);

  @override
  _SalesHistoryState createState() => _SalesHistoryState();
}

class _SalesHistoryState extends State<SalesHistory> {
  Future<void> _refreshData() async {
    setState(() {}); // Trigger rebuild to refresh data
  }

  @override
  Widget build(BuildContext context) {
    bool dark = HelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: dark ? CustomColors.black : CustomColors.lightestGrey,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            CustomPrimaryHeader(
              height: 150,
              child: Column(
                children: [
                  CustomAppBar(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to Inventocharm',
                          style: Theme.of(context).textTheme.labelMedium!.apply(
                                color: CustomColors.white,
                              ),
                        ),
                        Text(
                          'Sales History',
                          style: Theme.of(context).textTheme.titleLarge!.apply(
                                color: CustomColors.white,
                                fontWeightDelta: 2,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            RefreshIndicator(
              onRefresh: _refreshData,
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: FutureBuilder<List<RecordModel>>(
                  future:
                      pocketBase.collection('sales').getFullList(sort: '-date'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            const Text('No sales data available'),
                            IconButton(
                                onPressed: _refreshData,
                                icon: const Icon(
                                    FontAwesomeIcons.arrowRotateRight)),
                          ],
                        ),
                      );
                    }

                    final salesData = snapshot.data!
                        .map((record) => {'id': record.id, ...record.data})
                        .toList();

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: salesData.length,
                      itemBuilder: (context, index) {
                        final data = salesData[index];
                        // Calculating the correct index from the first sale recorded
                        final customerName = data['customerName'] ?? 'Unkown';
                        return SalesItemCard(
                          data: data,
                          customerName: customerName,
                        );
                      },
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
