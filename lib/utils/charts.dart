import 'package:audioapp/models/chartsmodel.dart';
import 'package:flutter/material.dart';

class ChartslistCard extends StatelessWidget {
  final Chart chart;
  const ChartslistCard({super.key, required this.chart, required this.onSelectedChart});
  final Function(Chart chart) onSelectedChart;
  @override
  Widget build(BuildContext context) {
    String cleanTitel = chart.title.replaceAll(RegExp(r'&quot;'), '').trim();
    return InkWell(
      onTap: (){
        onSelectedChart(chart);
      },
      child: Container(
         height: 40,
          width: 110,
          margin: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              chart.image.isNotEmpty
                  ? Image.network(
                      chart.image[2]['link'],
                      height: 100,
                      width: 100,
                    )
                  : Icon(Icons.image),
              const SizedBox(
                height: 20,
              ),
              Text(
                cleanTitel,
                overflow: TextOverflow.ellipsis,
              maxLines: 1,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color.fromARGB(240, 0, 0, 0),
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
      ),
    );
  }
}