import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:pitbus_app/services/RequestServ.dart';
import 'package:pitbus_app/services/context_app.dart';
import '../models/job_appointment_model.dart';

class JobValidateViewModel extends ChangeNotifier {
  final Map<int, bool> _loadingStates = {};
  final Map<int, List<JobValidateModel>> _jobsByAppointment = {};

  bool isAppointmentLoading(int id) => _loadingStates[id] ?? false;
  List<JobValidateModel> getJobsByAppointment(int id) => _jobsByAppointment[id] ?? [];

  RequestServ serv = RequestServ.instance;

  Future<void> fetchGetJobByAppointment(int idAppointment) async {
    // Evitar peticiones duplicadas si ya está cargando o ya tiene datos
    if (_loadingStates[idAppointment] == true || _jobsByAppointment.containsKey(idAppointment)) return;

    _loadingStates[idAppointment] = true;
    notifyListeners();

    try {
      print("Fetching job for appointment: $idAppointment");

      ResponseJobCite? responseJob = await serv.handlingRequestParsed(
        urlParam: "/api/appPitwall/citas",
        method: "GET",
        params: {
          "action" : "getDetailReport",
          "id" : "$idAppointment"
        },
        fromJson: (json) {
          print("json (id: $idAppointment) => $json");
          return ResponseJobCite.fromJson(json);
        }
      );

      if (responseJob != null) {
        _jobsByAppointment[idAppointment] = responseJob.data.map((element) => JobValidateModel(
          id: element.id,
          idPreOdt: element.idPreOdt,
          id_usuario_valida: ContextApp().idUser,
          descripcion: element.descripcion,
          status: element.status,
        )).toList();
      } else {
        _jobsByAppointment[idAppointment] = [];
      }

      notifyListeners();

    } catch (e) {
      print("[ ERROR JobValidateViewModel ] fetchGetJobByAppointment (id: $idAppointment) => $e");
    } finally {
      _loadingStates[idAppointment] = false;
      notifyListeners();
    }
  }

  void updateJobStatus(int appointmentId, int jobId, String newStatus) {
    final jobs = _jobsByAppointment[appointmentId];
    if (jobs != null) {
      final index = jobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        jobs[index].status = newStatus;
        notifyListeners();
      }
    }
  }

  Future<bool> sendValidateJobs(int appointmentId) async {

    final jobsToSend = _jobsByAppointment[appointmentId];
    if (jobsToSend == null || jobsToSend.isEmpty) return false;

    List<Map<String, dynamic>> params = [];

    for (var job in jobsToSend) {

      int statusValue = switch (job.status) {
        "Aceptada" => 1,
        _ => 2
      };

      params.add({
        "id": job.id,
        "id_usuario_valida": ContextApp().idUser,
        "status": statusValue
      });
    }

    try {

      final body = {
        "action": "qualify",
        "fails": params
      };

      print("SEND JSON => ${jsonEncode(body)}");

      final response = await serv.handlingRequestParsed(
        urlParam: "/api/appPitwall/citas/",
        method: "POST",
        params: body,
        asJson: true,
        fromJson: (json) => json,
      );

      print("Response Qualify (id: $appointmentId) => $response");

      return response?["success"] == true;

    } catch (e) {

      print("[ ERROR JobValidateViewModel ] sendValidateJobs (id: $appointmentId) => $e");
      return false;

    }
  }

  // Compatibilidad con código anterior si es necesario
  bool get isLoading => _loadingStates.values.any((loading) => loading);
  List<JobValidateModel> get jobs => _jobsByAppointment.values.expand((x) => x).toList();
}

class JobValidateModel {
  final int id;
  final int idPreOdt;
  final int id_usuario_valida;
  final String descripcion;
  String status;

  JobValidateModel({
    required this.id,
    required this.idPreOdt,
    required this.id_usuario_valida,
    required this.descripcion,
    required this.status,
  });
}
