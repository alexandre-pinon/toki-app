class Instruction {
  final int stepNumber;
  final String instruction;

  Instruction(this.stepNumber, this.instruction);

  Instruction.fromJson(dynamic json)
      : stepNumber = json['step_number'],
        instruction = json['instruction'];

  Map<String, dynamic> toJson() {
    return {
      'step_number': stepNumber,
      'instruction': instruction,
    };
  }
}
