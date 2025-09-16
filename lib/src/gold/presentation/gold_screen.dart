import 'dart:async';
import 'package:flutter/material.dart';

import 'package:gold_stream_app/src/gold/data/fake_gold_api.dart';
import 'package:gold_stream_app/src/gold/presentation/widgets/gold_header.dart';

class GoldScreen extends StatefulWidget {
  const GoldScreen({super.key});

  @override
  State<GoldScreen> createState() => _GoldScreenState();
}

class _GoldScreenState extends State<GoldScreen> {
  late final Stream<double> _priceStream;
  StreamSubscription<double>? _sub;

  @override
  void initState() {
    super.initState();

    _priceStream = getGoldPriceStream();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String _fmt(double v) => v.toStringAsFixed(2).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Goldpreis – Live')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GoldHeader(),
            const SizedBox(height: 24),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: StreamBuilder<double>(
                  stream: _priceStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          Text(
                            'Lade aktuellen Goldpreis...',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      );
                    }

                    if (snapshot.hasError) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 32,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Fehler: ${snapshot.error}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }

                    if (!snapshot.hasData) {
                      return Text(
                        'Noch keine Daten empfangen.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      );
                    }

                    final price = snapshot.data!;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_fmt(price)} € / g',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'aktualisiert in Echtzeit',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Quelle: getGoldPriceStream()',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
