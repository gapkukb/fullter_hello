import 'package:dio/dio.dart';
import 'package:hello/http/index.dart';

final config = Http.get("/login", {} as RequestOptions);
