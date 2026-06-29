import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../providers/family_vote_provider.dart';
import '../providers/planner_provider.dart';
import '../providers/recipe_provider.dart';

enum _Phase { pick, voting, result }

/// Family Vote: the host picks candidate dishes from the full catalog, the
/// family passes the phone and taps to vote, then the winner is revealed.
/// Fully local — no accounts, no backend.
class FamilyVoteScreen extends ConsumerStatefulWidget {
  const FamilyVoteScreen({super.key});

  @override
  ConsumerState<FamilyVoteScreen> createState() => _FamilyVoteScreenState();
}

class _FamilyVoteScreenState extends ConsumerState<FamilyVoteScreen> {
  _Phase _phase = _Phase.pick;
  String? _winnerId;

  void _restart() {
    ref.read(familyVoteProvider.notifier).reset();
    setState(() {
      _phase = _Phase.pick;
      _winnerId = null;
    });
  }

  void _reveal(FamilyVoteState state) {
    final winners = state.winners;
    setState(() {
      _winnerId = winners.length == 1 ? winners.first : null;
      _phase = _Phase.result;
    });
  }

  void _pickRandom(List<String> tied) {
    final pick = tied[Random().nextInt(tied.length)];
    setState(() => _winnerId = pick);
  }

  String _todayKey() => plannerDayKeys[DateTime.now().weekday - 1];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = ref.watch(familyVoteProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.familyVoteTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (state.candidateIds.isNotEmpty)
            IconButton(
              tooltip: l.voteNewSession,
              icon: const Icon(Icons.refresh),
              onPressed: _restart,
            ),
        ],
      ),
      body: switch (_phase) {
        _Phase.pick => _buildPick(state),
        _Phase.voting => _buildVoting(state),
        _Phase.result => _buildResult(state),
      },
    );
  }

  // ---- Phase 1: pick candidates ------------------------------------------

  Widget _buildPick(FamilyVoteState state) {
    final l = context.l10n;
    final recipes = ref.watch(recipesProvider);
    final byId = {for (final r in recipes) r.id: r};
    final canStart = state.candidateIds.length >= 2;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              const Text('🗳️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l.votePickCandidates,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.candidateIds.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(l.voteEmptyHint,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    for (final id in state.candidateIds)
                      if (byId[id] != null)
                        Card(
                          child: ListTile(
                            leading: Text(byId[id]!.emoji,
                                style: const TextStyle(fontSize: 24)),
                            title: Text(byId[id]!.title),
                            trailing: IconButton(
                              icon: const Icon(Icons.close,
                                  color: AppColors.textSecondary),
                              onPressed: () => ref
                                  .read(familyVoteProvider.notifier)
                                  .removeCandidate(id),
                            ),
                          ),
                        ),
                  ],
                ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                OutlinedButton.icon(
                  onPressed: _openPicker,
                  icon: const Icon(Icons.add),
                  label: Text(l.voteAddDish),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: canStart
                      ? () => setState(() => _phase = _Phase.voting)
                      : null,
                  icon: const Icon(Icons.how_to_vote),
                  label: Text(l.voteStart),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _CandidatePickerSheet(),
    );
  }

  // ---- Phase 2: voting ----------------------------------------------------

  Widget _buildVoting(FamilyVoteState state) {
    final l = context.l10n;
    final recipes = ref.watch(recipesProvider);
    final byId = {for (final r in recipes) r.id: r};

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(l.voteTapHint,
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              for (final id in state.candidateIds)
                if (byId[id] != null)
                  Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () =>
                          ref.read(familyVoteProvider.notifier).castVote(id),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Text(byId[id]!.emoji,
                                style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(byId[id]!.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                            ),
                            if (state.votesFor(id) > 0)
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: AppColors.textSecondary, size: 20),
                                onPressed: () => ref
                                    .read(familyVoteProvider.notifier)
                                    .undoVote(id),
                              ),
                            CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Text('${state.votesFor(id)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed:
                  state.totalVotes > 0 ? () => _reveal(state) : null,
              icon: const Icon(Icons.emoji_events),
              label: Text(l.voteReveal),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: AppColors.accent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---- Phase 3: result ----------------------------------------------------

  Widget _buildResult(FamilyVoteState state) {
    final l = context.l10n;
    final recipes = ref.watch(recipesProvider);
    final byId = {for (final r in recipes) r.id: r};
    final winners = state.winners;

    // Unresolved tie: let the family break it with a random pick.
    if (_winnerId == null && winners.length > 1) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🤝', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 12),
              Text(l.voteTie,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final id in winners)
                    if (byId[id] != null)
                      Chip(label: Text('${byId[id]!.emoji} ${byId[id]!.title}')),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _pickRandom(winners),
                icon: const Icon(Icons.casino),
                label: Text(l.votePickRandom),
              ),
            ],
          ),
        ),
      );
    }

    final winner = _winnerId != null ? byId[_winnerId] : null;
    if (winner == null) {
      // No votes / winner missing — shouldn't normally happen.
      return Center(child: Text(l.voteEmptyHint));
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            const Text('🏆', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 8),
            Text(l.voteWinner,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${winner.emoji} ${winner.title}',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(l.voteCount(state.votesFor(winner.id)),
                style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => context.push('/recipe/${winner.id}'),
              icon: const Icon(Icons.restaurant_menu),
              label: Text(context.l10n.viewRecipe),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(plannerProvider.notifier)
                    .setMeal(_todayKey(), winner.id);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text(l.voteAddedToPlanner),
                    duration: const Duration(seconds: 3),
                  ));
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(l.voteAddedToPlanner),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      ref.read(familyVoteProvider.notifier).resetVotes();
                      setState(() {
                        _winnerId = null;
                        _phase = _Phase.voting;
                      });
                    },
                    child: Text(l.voteAgain),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: _restart,
                    child: Text(l.voteNewSession),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Searchable, multi-select sheet to add/remove candidate dishes from the full
/// catalog. Stays open so the host can pick several in a row.
class _CandidatePickerSheet extends ConsumerStatefulWidget {
  const _CandidatePickerSheet();

  @override
  ConsumerState<_CandidatePickerSheet> createState() =>
      _CandidatePickerSheetState();
}

class _CandidatePickerSheetState extends ConsumerState<_CandidatePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final query = _query.toLowerCase().trim();
    final selected = ref.watch(familyVoteProvider).candidateIds.toSet();
    final recipes = ref.watch(recipesProvider).where((r) {
      if (query.isEmpty) return true;
      return r.title.toLowerCase().contains(query);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.voteAddDish, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: l.plannerSearchDish,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, i) {
                final r = recipes[i];
                final isSelected = selected.contains(r.id);
                return ListTile(
                  leading: Text(r.emoji, style: const TextStyle(fontSize: 24)),
                  title: Text(r.title),
                  trailing: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.add_circle_outline,
                    color:
                        isSelected ? AppColors.success : AppColors.primary,
                  ),
                  onTap: () {
                    final notifier = ref.read(familyVoteProvider.notifier);
                    isSelected
                        ? notifier.removeCandidate(r.id)
                        : notifier.addCandidate(r.id);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.done),
            ),
          ),
        ],
      ),
    );
  }
}
