import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _id;
  String _token;
  DateTime _expiryTime;
  Timer logoutTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryTime != null &&
        _expiryTime.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _id;
  }

  Future<void> authenticate(
      String email, String password, String changedSection) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$changedSection?key=AIzaSyCk6mFEEdwFyv33KRuQEvcOotaORGKoJa4');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseBody = json.decode(response.body);
      if (responseBody['error'] != null) {
        throw HttpException(responseBody['error']['message']);
      }
      _id = responseBody['localId'];
      _token = responseBody['idToken'];
      _expiryTime = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseBody['expiresIn'],
          ),
        ),
      );
      autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      String userData = json.encode({
        'id': _id,
        'expiryTime': _expiryTime.toIso8601String(),
        'token': _token,
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('userData')) {
      return false;
    }

    final Map<String, Object> userData =
        json.decode(prefs.getString('userData'));

    if (DateTime.parse(userData['expiryTime']).isBefore(DateTime.now())) {
      return false;
    }

    _expiryTime = DateTime.parse(userData['expiryTime']);
    _token = userData['token'];
    _id = userData['id'];
    notifyListeners();
    return true;
  }

  void logout() async {
    _expiryTime = null;
    _id = null;
    _token = null;
    if (logoutTimer != null) {
      logoutTimer.cancel();
      logoutTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void autoLogout() {
    if (logoutTimer != null) {
      logoutTimer.cancel();
    }
    final timeDifference = _expiryTime.difference(DateTime.now()).inSeconds;
    logoutTimer = Timer(Duration(seconds: timeDifference), logout);
  }
}
