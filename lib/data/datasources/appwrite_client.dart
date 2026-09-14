import 'package:appwrite/appwrite.dart';
import '../../core/config/appwrite_config.dart';

Client createAppwriteClient() => Client()
    .setEndpoint(AppwriteConfig.endpoint)
    .setProject(AppwriteConfig.projectId);
