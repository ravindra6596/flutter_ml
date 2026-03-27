import 'package:flutter/material.dart';
import 'package:flutter_ai_ml/bloc/entity_extraction/entity_extraction_bloc.dart';
import 'package:flutter_ai_ml/bloc/entity_extraction/entity_extraction_event.dart';
import 'package:flutter_ai_ml/bloc/entity_extraction/entity_extraction_state.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_appbar.dart';
import 'package:flutter_ai_ml/custom_widgets/custom_button.dart';
import 'package:flutter_ai_ml/utils/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EntityExtractionScreen extends StatefulWidget {
  const EntityExtractionScreen({super.key});

  @override
  State<EntityExtractionScreen> createState() => _EntityExtractionScreenState();
}

class _EntityExtractionScreenState extends State<EntityExtractionScreen> {
  final TextEditingController entityTextController = TextEditingController();
  EntityExtractionBloc entityExtractionBloc = EntityExtractionBloc();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => entityExtractionBloc,
      child: Scaffold(
        appBar: CustomAppBar(title: entityExtraction),
        body: BlocBuilder<EntityExtractionBloc, EntityExtractionState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: entityTextController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter text to extract entities",
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    onPressed: () {
                      entityExtractionBloc.add(InputEntityTextEvent(entityTextController.text));
                    },
                    text: extractEntity,
                  ),
                  const SizedBox(height: 24),
                  if (state is EntityExtractionLoading)
                    const CircularProgressIndicator(),
                  if (state is EntityExtractionError)
                    Text(state.message, style: const TextStyle(color: Colors.red)),
                  if (state is EntityExtractionLoaded)
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.annotations.length,
                        itemBuilder: (context, index) {
                          final annotation = state.annotations[index];
                          return ListTile(
                            title: Text(annotation.text),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: annotation.entities
                                  .map((e) => Text(e.type.toString()))
                                  .toList(),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}