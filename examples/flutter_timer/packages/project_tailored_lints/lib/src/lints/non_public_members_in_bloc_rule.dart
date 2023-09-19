import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class NonPublicMembersInBlocRule extends DartLintRule {
  NonPublicMembersInBlocRule() : super(code: _code);

  static const _publicMethodNamesWhitelist = <String>[
    'close',
  ];

  static const _metadataWhitelist = <String>[
    'protected',
    'visibleForTesting',
  ];

  static const _code = LintCode(
    name: 'no_public_class_members_in_bloc',
    problemMessage:
        'A bloc should expose its data through states and allow modifications '
        'only though events, the rest should be encapsulated.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration(
      (node) {
        if (node.name.lexeme.endsWith('Bloc')) {
          for (var member in node.members) {
            if (member is FieldDeclaration) {
              member.childEntities.forEach(
                (element) {
                  if (element is VariableDeclarationList) {
                    for (var variable in element.variables) {
                      if (_ruleIsViolated(variable.name, member.metadata)) {
                        reporter.reportErrorForNode(code, member);
                      }
                    }
                  }
                },
              );
            } else if (member is MethodDeclaration) {
              if (_ruleIsViolated(member.name, member.metadata)) {
                reporter.reportErrorForNode(code, member);
              }
            }
          }
        }
      },
    );
  }

  bool _ruleIsViolated(Token token, List<Annotation> metadataList) {
    return _isNonPrivateAndNotWhitelistedName(token) &&
        _hasNoWhitelistedMetadata(metadataList);
  }

  bool _isNonPrivateAndNotWhitelistedName(Token token) {
    return !Identifier.isPrivateName(token.lexeme) &&
        !_publicMethodNamesWhitelist.contains(token.lexeme);
  }

  bool _hasNoWhitelistedMetadata(List<Annotation> metadataList) {
    return !(metadataList
        .any((metadata) => _metadataWhitelist.contains(metadata.name.name)));
  }
}
