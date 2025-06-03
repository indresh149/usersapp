import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../models/todo_model.dart';
import '../../../core/constants/app_constants.dart';

class AppDatabase {
  static Future<void> initHive() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Register Adapters
    if (!Hive.isAdapterRegistered(UserAdapter().typeId)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(AddressAdapter().typeId)) { // Register Address adapter
      Hive.registerAdapter(AddressAdapter());
    }
    if (!Hive.isAdapterRegistered(PostAdapter().typeId)) {
      Hive.registerAdapter(PostAdapter());
    }
    if (!Hive.isAdapterRegistered(TodoAdapter().typeId)) {
      Hive.registerAdapter(TodoAdapter());
    }
    

    // Open Boxes
    await Hive.openBox<User>(AppConstants.hiveUserBox);
    await Hive.openBox<Post>(AppConstants.hivePostBox);
    await Hive.openBox<Todo>(AppConstants.hiveTodoBox);
  }
}