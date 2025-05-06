import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jebek_app/models/settings_model.dart';
import 'package:provider/provider.dart';

enum SalesPeriod {
  allTime,
  currentMonth,
  previousMonth,
  /*   last7Days,
  last30Days, */
  thisWeek,
  lastWeek,
  /*   thisQuarter,
  lastQuarter, */
  thisYear,
  lastYear,
  custom,
}

//pro sales periods
final List<SalesPeriod> proSalesPeriods = [
  SalesPeriod.allTime,
  SalesPeriod.previousMonth,
  SalesPeriod.lastWeek,
  SalesPeriod.lastYear,
  SalesPeriod.custom,
];

class TimeIntervalSelector extends StatefulWidget {
  final SalesPeriod period;

  final void Function(
    SalesPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  )
  onPeriodChanged;

  const TimeIntervalSelector({
    Key? key,
    required this.onPeriodChanged,
    required this.period,
  }) : super(key: key);

  @override
  _TimeIntervalSelectorState createState() => _TimeIntervalSelectorState();
}

class _TimeIntervalSelectorState extends State<TimeIntervalSelector> {
  late SalesPeriod _selectedPeriod = widget.period;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  late Settings settings;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.period;
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime initialDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _customStartDate = picked;
        } else {
          _customEndDate = picked;
        }
      });
      widget.onPeriodChanged(_selectedPeriod, _customStartDate, _customEndDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    settings = context.watch<Settings>();
    final periodNames = {
      SalesPeriod.allTime: "Todo el Tiempo",
      SalesPeriod.currentMonth: "Mes Actual",
      SalesPeriod.previousMonth: "Mes Anterior",
      /* SalesPeriod.last7Days: "Últimos 7 Días",
      SalesPeriod.last30Days: "Últimos 30 Días", */
      SalesPeriod.thisWeek: "Esta Semana",
      SalesPeriod.lastWeek: "Semana Pasada",
      /*  SalesPeriod.thisQuarter: "Este Trimestre",
      SalesPeriod.lastQuarter: "Trimestre Anterior", */
      SalesPeriod.thisYear: "Este Año",
      SalesPeriod.lastYear: "Año Anterior",
      SalesPeriod.custom: "Personalizado",
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<SalesPeriod>(
          value: _selectedPeriod,

          isExpanded: true,
          items:
              SalesPeriod.values.map((period) {
                return DropdownMenuItem<SalesPeriod>(
                  enabled:
                      settings.isProVersion ||
                      !proSalesPeriods.contains(period),
                  value: period,
                  child:
                      (settings.isProVersion ||
                              !proSalesPeriods.contains(period))
                          ? Text(periodNames[period] ?? "")
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                periodNames[period] ?? "",
                                style: const TextStyle(color: Colors.grey),
                              ),

                              const Icon(
                                Icons.diamond,
                                color: Colors.red,
                                size: 16,
                              ),
                            ],
                          ),
                );
              }).toList(),
          onChanged: (newVal) {
            if (newVal != null) {
              setState(() {
                _selectedPeriod = newVal;
              });
              widget.onPeriodChanged(
                _selectedPeriod,
                _customStartDate,
                _customEndDate,
              );
            }
          },
        ),
        if (_selectedPeriod == SalesPeriod.custom)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Fecha Inicio",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _customStartDate == null
                            ? "Seleccionar fecha"
                            : DateFormat(
                              'yyyy-MM-dd',
                            ).format(_customStartDate!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Fecha Fin",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _customEndDate == null
                            ? "Seleccionar fecha"
                            : DateFormat('yyyy-MM-dd').format(_customEndDate!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
