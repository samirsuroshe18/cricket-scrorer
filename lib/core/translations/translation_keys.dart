class TranslationKeys {
  TranslationKeys._();

  static const String login = 'login';
  static const String logout = 'logout';
  static const String email = 'email';
  static const String password = 'password';
  static const String forgotPassword = 'forgot_password';
  static const String forgotPasswordDesc = 'forgot_password_desc';
  static const String cancel = 'cancel';
  static const String retry = 'retry';
  static const String confirm = 'confirm';
  static const String selectYourLanguage = 'select_your_language';
  static const String selectYourTheme = 'select_your_theme';
  static const String camera = 'camera';
  static const String gallery = 'gallery';
  static const String light = 'light';
  static const String dark = 'dark';
  static const String system = 'system';
  static const String language = 'language';
  static const String theme = 'theme';
  static const String sessionExpired = 'session_expired';
  static const String inputFileNotExists = 'input_file_not_exists';
  static const String compressionMissingOutput = 'compression_missing_output';
  static const String compressionFailed = 'compression_failed';
  static const String emailRequired = 'email_required';
  static const String enterValidEmail = 'enter_valid_email';
  static const String passwordRequired = 'password_required';
  static const String passwordTooShort = 'password_too_short';
  static const String failedToSaveSession = 'failed_to_save_session';
  static const String liveScoring = 'live_scoring';
  static const String liveScoringDesc = 'live_scoring_desc';
  static const String deepMatchStats = 'deep_match_stats';
  static const String deepMatchStatsDesc = 'deep_match_stats_desc';
  static const String shareTheVictory = 'share_the_victory';
  static const String shareTheVictoryDesc = 'share_the_victory_desc';
  static const String enterCompleteCode = 'enter_complete_code';
  static const String fullNameRequired = 'full_name_required';
  static const String nameTooShort = 'name_too_short';
  static const String confirmPasswordRequired = 'confirm_password_required';
  static const String passwordsDoNotMatch = 'passwords_do_not_match';
  static const String resetTokenMissing = 'reset_token_missing';
  static const String addProfilePhoto = 'add_profile_photo';
  static const String usernameRequired = 'username_required';
  static const String usernameTooShort = 'username_too_short';
  static const String enterEmail = 'enter_email';
  static const String sendResetCode = 'send_reset_code';
  static const String rememberedPassword = 'remembered_password';
  static const String cricketScorer = 'cricket_scorer';
  static const String trackEveryBall = 'track_every_ball';
  static const String enterPassword = 'enter_password';
  static const String dontHaveAccount = 'dont_have_account';
  static const String register = 'register';
  static const String skip = 'skip';
  static const String getStarted = 'get_started';
  static const String next = 'next';
  static const String verifyYourAccount = 'verify_your_account';
  static const String otpVerificationDesc = 'otp_verification_desc';
  static const String verify = 'verify';
  static const String resend = 'resend';
  static const String resendCodeIn = 'resend_code_in';
  static const String didNotReceiveCode = 'did_not_receive_code';
  static const String createAccount = 'create_account';
  static const String joinAndStartScoring = 'join_and_start_scoring';
  static const String fullName = 'full_name';
  static const String enterFullName = 'enter_full_name';
  static const String confirmPassword = 'confirm_password';
  static const String enterConfirmPassword = 'enter_confirm_password';
  static const String alreadyHaveAccount = 'already_have_account';
  static const String setNewPassword = 'set_new_password';
  static const String setNewPasswordDesc = 'set_new_password_desc';
  static const String newPassword = 'new_password';
  static const String enterNewPassword = 'enter_new_password';
  static const String confirmNewPassword = 'confirm_new_password';
  static const String enterConfirmNewPassword = 'enter_confirm_new_password';
  static const String resetPassword = 'reset_password';
  static const String completeProfile = 'complete_profile';
  static const String username = 'username';
  static const String enterUsername = 'enter_username';
  static const String tellUsAboutYourself = 'tell_us_about_yourself';
  static const String bio = 'bio';
  static const String battingStyle = 'batting_style';
  static const String bowlingStyle = 'bowling_style';
  static const String rightHanded = 'right_handed';
  static const String leftHanded = 'left_handed';
  static const String rightArmPace = 'right_arm_pace';
  static const String leftArmPace = 'left_arm_pace';
  static const String rightArmSpin = 'right_arm_spin';
  static const String leftArmSpin = 'left_arm_spin';
  static const String continueText = 'continue_text';
  static const String myProfile = 'my_profile';
  static const String saveChanges = 'save_changes';

  /// Player career-stats screen
  static const String playerStats = 'player_stats';
  static const String matchesPlayed = 'matches_played';
  static const String innings = 'innings';
  static const String average = 'average';
  static const String highScore = 'high_score';
  static const String fifties = 'fifties';
  static const String hundreds = 'hundreds';
  static const String bestBowling = 'best_bowling';

  static const String cricketMatch = 'cricket_match';
  static const String passwordWeak = 'password_weak';
  static const String passwordFair = 'password_fair';
  static const String passwordGood = 'password_good';
  static const String passwordStrong = 'password_strong';

  /// Failure messages — defaults for the [CricketFailure] hierarchy.
  static const String connectionError = 'connection_error';
  static const String serverError = 'server_error';
  static const String badRequestError = 'bad_request_error';
  static const String unAuthorizedError = 'unauthorized_error';
  static const String forbiddenError = 'forbidden_error';
  static const String notFoundError = 'not_found_error';
  static const String somethingWentWrong = 'something_went_wrong';
  static const String genericErrorMessage = 'generic_error_message';
  static const String genericAlertMessage = 'generic_alert_message';

  /// Scoring feature
  static const String startMatch = 'start_match';
  static const String createMatch = 'create_match';
  static const String teamAName = 'team_a_name';
  static const String teamBName = 'team_b_name';
  static const String overs = 'overs';
  static const String enterTeamAName = 'enter_team_a_name';
  static const String enterTeamBName = 'enter_team_b_name';
  static const String enterOvers = 'enter_overs';
  static const String teamNameRequired = 'team_name_required';
  static const String invalidOvers = 'invalid_overs';
  static const String teamNamesMustDiffer = 'team_names_must_differ';
  static const String reuseExistingTeam = 'reuse_existing_team';

  /// Toss (optional at match creation)
  static const String tossOptional = 'toss_optional';
  static const String teamA = 'team_a';
  static const String teamB = 'team_b';
  static const String tossWinner = 'toss_winner';
  static const String tossDecision = 'toss_decision';
  static const String bat = 'bat';
  static const String bowl = 'bowl';
  static const String tossIncomplete = 'toss_incomplete';
  static const String wonTheToss = 'won_the_toss';
  static const String electedTo = 'elected_to';
  static const String tapToFlip = 'tap_to_flip';
  static const String tapToReflip = 'tap_to_reflip';

  static const String liveScore = 'live_score';
  static const String selectRuns = 'select_runs';
  static const String wickets = 'wickets';
  static const String connectionLost = 'connection_lost';
  static const String extras = 'extras';
  static const String wideOrNoBall = 'wide_or_no_ball';
  static const String wide = 'wide';
  static const String noBall = 'no_ball';
  static const String byeOrLegBye = 'bye_or_leg_bye';
  static const String bye = 'bye';
  static const String legBye = 'leg_bye';

  /// Rate tracking
  static const String currentRunRateShort = 'current_run_rate_short';
  static const String requiredRunRateShort = 'required_run_rate_short';
  static const String partnership = 'partnership';

  /// Batsmen & strike
  static const String striker = 'striker';
  static const String nonStriker = 'non_striker';
  static const String openingBatsmen = 'opening_batsmen';
  static const String chooseOpeners = 'choose_openers';
  static const String enterStrikerName = 'enter_striker_name';
  static const String enterNonStrikerName = 'enter_non_striker_name';
  static const String startInnings = 'start_innings';
  static const String batsmanNameRequired = 'batsman_name_required';
  static const String batsmenMustDiffer = 'batsmen_must_differ';
  static const String endOfOver = 'end_of_over';
  static const String inningsOneComplete = 'innings_one_complete';

  /// Bowlers
  static const String openingPlayers = 'opening_players';
  static const String openingBowler = 'opening_bowler';
  static const String currentBowler = 'current_bowler';
  static const String selectBowler = 'select_bowler';
  static const String chooseBowler = 'choose_bowler';
  static const String bowlerName = 'bowler_name';
  static const String enterBowlerName = 'enter_bowler_name';
  static const String bowlerNameRequired = 'bowler_name_required';
  static const String cannotBowlConsecutiveOvers =
      'cannot_bowl_consecutive_overs';

  /// Undo
  static const String undoLastBall = 'undo_last_ball';

  /// Spectator
  static const String watchLiveMatch = 'watch_live_match';
  static const String enterMatchCodeDescription =
      'enter_match_code_description';
  static const String matchCode = 'match_code';
  static const String enterMatchCode = 'enter_match_code';
  static const String matchCodeRequired = 'match_code_required';
  static const String invalidShareLink = 'invalid_share_link';
  static const String waitingForPlayToBegin = 'waiting_for_play_to_begin';
  static const String matchCompleted = 'match_completed';
  static const String copyShareCode = 'copy_share_code';
  static const String codeCopied = 'code_copied';

  /// Wickets
  static const String out = 'out';
  static const String howOut = 'how_out';
  static const String bowled = 'bowled';
  static const String caught = 'caught';
  static const String lbw = 'lbw';
  static const String runOut = 'run_out';
  static const String stumped = 'stumped';
  static const String hitWicket = 'hit_wicket';
  static const String whoIsOut = 'who_is_out';
  static const String runsCompleted = 'runs_completed';
  static const String newBatsman = 'new_batsman';
  static const String enterNewBatsmanName = 'enter_new_batsman_name';
  static const String confirmWicket = 'confirm_wicket';
  static const String notPossibleOffNoBall = 'not_possible_off_no_ball';
  static const String notPossibleOffWide = 'not_possible_off_wide';
  static const String allOut = 'all_out';

  /// Result screen
  static const String matchResult = 'match_result';
  static const String wonBy = 'won_by';
  static const String matchTied = 'match_tied';

  /// The natural-language word, for the result sentence — distinct from
  /// [runsShort], the table-column abbreviation.
  static const String runsWord = 'runs_word';
  static const String battingFigures = 'batting_figures';
  static const String bowlingFigures = 'bowling_figures';
  static const String batter = 'batter';
  static const String bowler = 'bowler';
  static const String notOut = 'not_out';
  static const String runsShort = 'runs_short';
  static const String ballsShort = 'balls_short';
  static const String foursShort = 'fours_short';
  static const String sixesShort = 'sixes_short';
  static const String strikeRateShort = 'strike_rate_short';
  static const String oversShort = 'overs_short';
  static const String maidensShort = 'maidens_short';
  static const String wicketsShort = 'wickets_short';
  static const String economyShort = 'economy_short';
  static const String widesShort = 'wides_short';
  static const String noBallsShort = 'no_balls_short';

  // Offline sync
  static const String syncConflict = 'sync_conflict';
  static const String syncConflictTitle = 'sync_conflict_title';
  static const String syncConflictMessage = 'sync_conflict_message';
  static const String discardAndReload = 'discard_and_reload';
  static const String reviewLater = 'review_later';
  static const String unsyncedDeliveries = 'unsynced_deliveries';
  static const String syncBlockedOnRule = 'sync_blocked_on_rule';
  static const String syncBlockedTitle = 'sync_blocked_title';
  static const String syncBlockedMessage = 'sync_blocked_message';
  static const String undoBackToHere = 'undo_back_to_here';
  static const String retrySync = 'retry_sync';
  static const String syncingNow = 'syncing_now';
  static const String scorecardPendingSync = 'scorecard_pending_sync';

  // Match history / home
  static const String matchHistory = 'match_history';
  static const String noMatchesYet = 'no_matches_yet';
  static const String noMatchesYetHint = 'no_matches_yet_hint';
  static const String statusUpcoming = 'status_upcoming';
  static const String statusLive = 'status_live';
  static const String statusInningsBreak = 'status_innings_break';
  static const String statusCompleted = 'status_completed';
  static const String statusAbandoned = 'status_abandoned';
  static const String abandonMatch = 'abandon_match';
  static const String abandonMatchConfirmTitle = 'abandon_match_confirm_title';
  static const String abandonMatchConfirmMessage =
      'abandon_match_confirm_message';
  static const String deleteMatch = 'delete_match';
  static const String deleteMatchConfirmTitle = 'delete_match_confirm_title';
  static const String deleteMatchConfirmMessage =
      'delete_match_confirm_message';

  // Team profile
  static const String teamProfile = 'team_profile';
  static const String pastResults = 'past_results';
  static const String roster = 'roster';
  static const String noRosterYet = 'no_roster_yet';
  static const String roleBatsman = 'role_batsman';
  static const String roleBowler = 'role_bowler';
  static const String roleAllrounder = 'role_allrounder';
  static const String roleWicketkeeper = 'role_wicketkeeper';
  static const String roleUnknown = 'role_unknown';

  // Organizations
  static const String organizations = 'organizations';
  static const String organizationDetail = 'organization_detail';
  static const String createOrganization = 'create_organization';
  static const String organizationName = 'organization_name';
  static const String organizationCreated = 'organization_created';
  static const String noOrganizationsYet = 'no_organizations_yet';
  static const String members = 'members';
  static const String addMember = 'add_member';
  static const String memberEmail = 'member_email';
  static const String memberAdded = 'member_added';
  static const String teams = 'teams';
  static const String addTeam = 'add_team';
  static const String teamName = 'team_name';
  static const String teamShortName = 'team_short_name';
  static const String teamAdded = 'team_added';
  static const String noTeamsYet = 'no_teams_yet';
  static const String add = 'add';
  static const String leaveOrganization = 'leave_organization';
  static const String leaveOrganizationConfirmTitle =
      'leave_organization_confirm_title';
  static const String leaveOrganizationConfirmMessage =
      'leave_organization_confirm_message';
  static const String removeMember = 'remove_member';
  static const String removeMemberConfirmTitle = 'remove_member_confirm_title';
  static const String removeMemberConfirmMessage =
      'remove_member_confirm_message';
  static const String deleteOrganization = 'delete_organization';
  static const String deleteOrganizationConfirmTitle =
      'delete_organization_confirm_title';
  static const String deleteOrganizationConfirmMessage =
      'delete_organization_confirm_message';
  static const String create = 'create';

  // Delegated scoring
  static const String assignScorer = 'assign_scorer';
  static const String removeAssignment = 'remove_assignment';
  static const String noScorerCandidates = 'no_scorer_candidates';
  static const String scorerAssigned = 'scorer_assigned';
  static const String scorerUnassigned = 'scorer_unassigned';
  static const String assignedByName = 'assigned_by_name';
  static const String assignedToName = 'assigned_to_name';
  static const String tapToHandOffScoring = 'tap_to_hand_off_scoring';
  static const String currentScorer = 'current_scorer';
}
