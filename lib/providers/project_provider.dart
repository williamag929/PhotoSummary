import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/project.dart';

class ProjectProvider with ChangeNotifier {
  List<Project> _projects = [];
  Project? _currentProject;

  List<Project> get projects => _projects;
  Project? get currentProject => _currentProject;

  Future<void> fetchProjects() async {
    _projects = await DatabaseHelper.instance.getProjects();
    if (_projects.isNotEmpty) {
      _currentProject = _projects.first;
    }
    notifyListeners();
  }

  Future<void> addProject(Project project) async {
    await DatabaseHelper.instance.insertProject(project);
    await fetchProjects();
  }

  Future<void> updateProject(Project project) async {
    await DatabaseHelper.instance.updateProject(project);
    await fetchProjects();
  }

  Future<void> deleteProject(int id) async {
    await DatabaseHelper.instance.deleteProject(id);
    await fetchProjects();
  }

  void switchProject(Project project) {
    _currentProject = project;
    notifyListeners();
  }
}
