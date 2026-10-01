import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inventocharm/components/constants/colors.dart';
import 'package:inventocharm/components/constants/helpers/helper_functions.dart';

class CustomSearchContainer extends StatefulWidget {
  const CustomSearchContainer({
    Key? key,
    required this.text,
    this.icon = FontAwesomeIcons.magnifyingGlass,
    this.showBackground = true,
    this.showBorder = true,
    this.onTextChanged,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final bool showBackground, showBorder;
  final Function(String)? onTextChanged;

  @override
  _CustomSearchContainerState createState() => _CustomSearchContainerState();
}

class _CustomSearchContainerState extends State<CustomSearchContainer> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _textEditingController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (widget.onTextChanged != null) {
      widget.onTextChanged!(_textEditingController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = HelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: widget.showBackground
              ? dark
                  ? CustomColors.black
                  : CustomColors.white
              : Colors.transparent,
          border: widget.showBorder
              ? Border.all(color: CustomColors.grey)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: dark ? CustomColors.white : CustomColors.black,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: (MediaQuery.sizeOf(context).height * 0.05)
                    .clamp(40.0, 52.0),
                child: TextField(
                  controller: _textEditingController,
                  enabled: true,
                  decoration: InputDecoration(
                    hintText: widget.text,
                    hintStyle: theme.textTheme.labelMedium!.copyWith(
                      color: dark ? CustomColors.white : CustomColors.black,
                    ),
                  ),
                  style: theme.textTheme.labelMedium!.copyWith(
                    color: dark ? CustomColors.white : CustomColors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_onTextChanged);
    _textEditingController.dispose();
    super.dispose();
  }
}
