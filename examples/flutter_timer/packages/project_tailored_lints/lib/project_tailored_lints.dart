library project_tailored_lints;

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:project_tailored_lints/src/lints/non_public_members_in_bloc_rule.dart';

PluginBase createPlugin() => _ProjectTailoredLintsPlugin();

class _ProjectTailoredLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        NonPublicMembersInBlocRule(),
      ];
}
