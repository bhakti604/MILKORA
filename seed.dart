// ignore_for_file: avoid_print
import 'lib/services/mongodb_service.dart';

void main() async {
  print("Connecting to MongoDB and creating MILKORA database...");
  await MongoDatabase.connect();
  print("Done! Check your Atlas dashboard now.");
}
