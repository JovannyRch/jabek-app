class Expense {
  final int id;
  final String concept;
  final int userId;
  final String amount;
  final String date;

  Expense({
    required this.id,
    required this.concept,
    required this.userId,
    required this.amount,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      concept: json['concept'],
      userId: json['user_id'],
      amount: json['amount'],
      date: json['date'],
    );
  }
}
