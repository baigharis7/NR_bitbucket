class EventsSynchronizationRequest {
  List<int> foodEvents;
  List<int> sportEvents;
  List<int> sportRoutines;
  List<int> liquidEvents;
  List<int> waterEvents;
  List<int> foodFavorites;
  List<int> sportFavorites;
  List<int> liquidFavorites;
  List<int> subjectiveAnalysis;

  EventsSynchronizationRequest({
    required this.foodEvents,
    required this.sportEvents,
    required this.sportRoutines,
    required this.liquidEvents,
    required this.waterEvents,
    required this.foodFavorites,
    required this.sportFavorites,
    required this.liquidFavorites,
    required this.subjectiveAnalysis,
  });

}