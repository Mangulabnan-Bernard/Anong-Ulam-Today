import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Immutable state of one family-vote session: the candidate recipe ids the
/// host picked, plus a tally of votes per candidate. Ephemeral — a session
/// lives only while the screen is open (no persistence needed).
class FamilyVoteState {
  const FamilyVoteState({
    this.candidateIds = const [],
    this.votes = const {},
  });

  final List<String> candidateIds;
  final Map<String, int> votes;

  int votesFor(String id) => votes[id] ?? 0;

  int get totalVotes => votes.values.fold(0, (sum, v) => sum + v);

  /// Candidate id(s) with the most votes. Can contain more than one id on a
  /// tie; empty when nobody has voted yet.
  List<String> get winners {
    if (votes.isEmpty) return const [];
    final max = votes.values.fold(0, (m, v) => v > m ? v : m);
    if (max == 0) return const [];
    return votes.entries
        .where((e) => e.value == max)
        .map((e) => e.key)
        .toList();
  }

  bool get isTie => winners.length > 1;

  FamilyVoteState copyWith({
    List<String>? candidateIds,
    Map<String, int>? votes,
  }) =>
      FamilyVoteState(
        candidateIds: candidateIds ?? this.candidateIds,
        votes: votes ?? this.votes,
      );
}

class FamilyVoteNotifier extends Notifier<FamilyVoteState> {
  @override
  FamilyVoteState build() => const FamilyVoteState();

  void addCandidate(String id) {
    if (state.candidateIds.contains(id)) return;
    state = state.copyWith(candidateIds: [...state.candidateIds, id]);
  }

  void removeCandidate(String id) {
    state = state.copyWith(
      candidateIds: state.candidateIds.where((c) => c != id).toList(),
      votes: {...state.votes}..remove(id),
    );
  }

  void castVote(String id) {
    if (!state.candidateIds.contains(id)) return;
    state = state.copyWith(
      votes: {...state.votes, id: (state.votes[id] ?? 0) + 1},
    );
  }

  /// Removes one vote from [id] (for mis-taps). No-op at zero.
  void undoVote(String id) {
    final current = state.votes[id] ?? 0;
    if (current <= 0) return;
    final next = {...state.votes};
    if (current == 1) {
      next.remove(id);
    } else {
      next[id] = current - 1;
    }
    state = state.copyWith(votes: next);
  }

  /// Clears votes but keeps the candidates (re-vote on the same dishes).
  void resetVotes() => state = state.copyWith(votes: const {});

  /// Clears everything (start a brand-new session).
  void reset() => state = const FamilyVoteState();
}

final familyVoteProvider =
    NotifierProvider<FamilyVoteNotifier, FamilyVoteState>(
  FamilyVoteNotifier.new,
);
