import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../state/app_providers.dart';
import 'save_link_page.dart';
import 'ui_primitives.dart';

class BrowserPage extends ConsumerStatefulWidget {
  const BrowserPage({
    super.key,
    this.initialInput,
    this.linkIdToTouch,
  });

  final String? initialInput;
  final int? linkIdToTouch;

  @override
  ConsumerState<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends ConsumerState<BrowserPage> {
  late final WebViewController _controller;
  late final TextEditingController _addressController;

  String _currentUrl = '';
  String _currentTitle = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialInput ?? '');
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _currentUrl = url;
              _addressController.text = url;
              _isLoading = true;
            });
          },
          onPageFinished: (url) async {
            final title = await _controller.getTitle() ?? '';
            if (!mounted) {
              return;
            }

            setState(() {
              _currentUrl = url;
              _currentTitle = title;
              _isLoading = false;
            });

            await ref.read(vaultControllerProvider.notifier).trackSession(
                  url: url,
                  title: title,
                );

            if (widget.linkIdToTouch case final linkId?) {
              await ref.read(vaultControllerProvider.notifier).touchLink(linkId);
            }
          },
        ),
      );

    if ((widget.initialInput ?? '').trim().isNotEmpty) {
      _openInput(widget.initialInput!);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _currentUrl.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 12,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AppPanel(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            radius: 26,
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded, color: Color(0xFF46B57E), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    textInputAction: TextInputAction.go,
                    decoration: const InputDecoration(
                      hintText: 'Search or enter an address',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: _openInput,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _isLoading
                      ? const SizedBox.square(
                          key: ValueKey('loading'),
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          key: const ValueKey('open'),
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          onPressed: () => _openInput(_addressController.text),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: AppBackground(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: AppPanel(
                  padding: const EdgeInsets.all(10),
                  radius: 34,
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: ColoredBox(
                            color: const Color(0xFFFFF3EF),
                            child: WebViewWidget(controller: _controller),
                          ),
                        ),
                      ),
                      if (canSave) ...[
                        const SizedBox(height: 12),
                        _SaveHintBar(
                          currentTitle: _currentTitle,
                          onSave: _saveCurrentPage,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 10),
                child: AppPanel(
                  radius: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _DockButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onPressed: () async {
                          if (await _controller.canGoBack()) {
                            await _controller.goBack();
                          }
                        },
                      ),
                      _DockButton(
                        icon: Icons.arrow_forward_ios_rounded,
                        onPressed: () async {
                          if (await _controller.canGoForward()) {
                            await _controller.goForward();
                          }
                        },
                      ),
                      _DockButton(
                        icon: Icons.bookmark_add_outlined,
                        filled: true,
                        onPressed: canSave ? _saveCurrentPage : null,
                      ),
                      _DockButton(
                        icon: Icons.refresh_rounded,
                        onPressed: () => _controller.reload(),
                      ),
                      _DockButton(
                        icon: Icons.menu_rounded,
                        onPressed: () => _showBrowserSheet(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCurrentPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SaveLinkPage(
          initialUrl: _currentUrl,
          initialTitle: _currentTitle,
        ),
      ),
    );
  }

  Future<void> _openInput(String rawInput) async {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final target = _normalizeInput(trimmed);
    await _controller.loadRequest(Uri.parse(target));
  }

  String _normalizeInput(String input) {
    final uri = Uri.tryParse(input);
    if (uri != null && uri.hasScheme) {
      return input;
    }

    final looksLikeHost = input.contains('.') && !input.contains(' ');
    if (looksLikeHost) {
      return 'https://$input';
    }

    return 'https://duckduckgo.com/?q=${Uri.encodeQueryComponent(input)}';
  }

  Future<void> _showBrowserSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: AppPanel(
            radius: 30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.bookmark_add_outlined),
                  title: const Text('Save current page'),
                  onTap: () {
                    Navigator.of(context).pop();
                    if (_currentUrl.isNotEmpty) {
                      _saveCurrentPage();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh_rounded),
                  title: const Text('Reload'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _controller.reload();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final background = filled ? const Color(0xFFFF6B6B) : const Color(0xFFFFF3EF);
    final foreground = filled ? Colors.white : const Color(0xFF826E78);

    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        minimumSize: const Size(42, 42),
      ),
      icon: Icon(icon, size: 18),
    );
  }
}

class _SaveHintBar extends StatelessWidget {
  const _SaveHintBar({
    required this.currentTitle,
    required this.onSave,
  });

  final String currentTitle;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: 22,
      backgroundColor: const Color(0xFFFFFCFB),
      child: Row(
        children: [
          const AppPill(label: 'Reading', compact: true, backgroundColor: Color(0xFFEEF4FF), foregroundColor: Color(0xFF5B84E3)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              currentTitle.isEmpty ? 'Ready to save this page into your vault' : currentTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onSave,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
