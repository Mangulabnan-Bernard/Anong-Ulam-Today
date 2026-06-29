// Unit tests for the Family Vote session logic (candidates, tally, winner,
// tie). Pure in-memory state — no Hive needed.
import 'package:anong_ulam_today/presentation/providers/family_vote_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  FamilyVoteNotifier notifier() =>
      container.read(familyVoteProvider.notifier);
  FamilyVoteState state() => container.read(familyVoteProvider);

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  test('addCandidate adds dishes and ignores duplicates', () {
    notifier()
      ..addCandidate('adobo')
      ..addCandidate('tinola')
      ..addCandidate('adobo');
    expect(state().candidateIds, ['adobo', 'tinola']);
  });

  test('votes only count for candidates and tally up', () {
    notifier()
      ..addCandidate('adobo')
      ..addCandidate('tinola')
      ..castVote('adobo')
      ..castVote('adobo')
      ..castVote('tinola')
      ..castVote('lechon'); // not a candidate — ignored
    expect(state().votesFor('adobo'), 2);
    expect(state().votesFor('tinola'), 1);
    expect(state().votesFor('lechon'), 0);
    expect(state().totalVotes, 3);
  });

  test('single winner is reported, no tie', () {
    notifier()
      ..addCandidate('adobo')
      ..addCandidate('tinola')
      ..castVote('adobo')
      ..castVote('adobo')
      ..castVote('tinola');
    expect(state().winners, ['adobo']);
    expect(state().isTie, isFalse);
  });

  test('equal top votes produce a tie', () {
    notifier()
      ..addCandidate('adobo')
      ..addCandidate('tinola')
      ..castVote('adobo')
      ..castVote('tinola');
    expect(state().winners.toSet(), {'adobo', 'tinola'});
    expect(state().isTie, isTrue);
  });

  test('no votes yet means no winner', () {
    notifier()
      ..addCandidate('adobo')
      ..addCandidate('tinola');
    expect(state().winners, isEmpty);
    expect(state().isTie, isFalse);
  });

  test('undoVote decrements and clears at zero', () {
    notifier()
      ..addCandidate('adobo')
      ..castVote('adobo')
      ..castVote('adobo')
      ..undoVote('adobo');
    expect(state().votesFor('adobo'), 1);
    notifier().undoVote('adobo');
    expect(state().votesFor('adobo'), 0);
    expect(state().totalVotes, 0);
    notifier().undoVote('adobo'); // no-op at zero
    expect(state().votesFor('adobo'), 0);
  });

  test('removeCandidate drops the dish and its votes', () {
    notifier()
      ..addCandidate('adobo')
      ..addCandidate('tinola')
      ..castVote('adobo')
      ..removeCandidate('adobo');
    expect(state().candidateIds, ['tinola']);
    expect(state().votesFor('adobo'), 0);
  });

  test('resetVotes keeps candidates; reset clears everything', () {
    notifier()
      ..addCandidate('adobo')
      ..addCandidate('tinola')
      ..castVote('adobo');
    notifier().resetVotes();
    expect(state().candidateIds, ['adobo', 'tinola']);
    expect(state().totalVotes, 0);

    notifier().reset();
    expect(state().candidateIds, isEmpty);
  });
}
