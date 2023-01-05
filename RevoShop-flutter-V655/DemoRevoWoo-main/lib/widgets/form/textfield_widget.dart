import 'package:flutter/material.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:flutter/services.dart';

class FormRevo extends StatefulWidget {
  final TextEditingController? txtController;
  final String? label;
  final String? hint;
  final bool? obscureText;
  final bool? isPhone;
  final bool? isVisiblePass;
  final bool? isNumber;
  const FormRevo(
      {Key? key,
      this.txtController,
      this.label,
      this.hint = '',
      this.obscureText = false,
      this.isPhone = false,
      this.isVisiblePass = false,
      this.isNumber = false})
      : super(key: key);

  @override
  State<FormRevo> createState() => _FormRevoState();
}

class _FormRevoState extends State<FormRevo> {
  bool? _isVisiblePass;
  bool? _isObscure;

  @override
  void initState() {
    super.initState();
    _isVisiblePass = widget.isVisiblePass;
    _isObscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 12,
          child: TextField(
            controller: widget.txtController,
            obscureText: _isObscure!,
            cursorColor: primaryColor,
            inputFormatters: widget.isNumber!
                ? <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[.0-9]')),
                  ]
                : null,
            keyboardType: widget.isPhone!
                ? TextInputType.phone
                : widget.isNumber!
                    ? TextInputType.number
                    : TextInputType.text,
            decoration: InputDecoration(
                hintText: widget.hint,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: responsiveFont(10),
                ),
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: responsiveFont(12),
                ),
                suffixIcon: widget.obscureText!
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            _isVisiblePass = !_isVisiblePass!;
                            _isObscure = !_isObscure!;
                          });
                        },
                        child: Container(
                            height: 10,
                            padding: EdgeInsets.all(5),
                            child: Image.asset(_isVisiblePass!
                                ? "images/account/melek.png"
                                : "images/account/merem.png")),
                      )
                    : null,
                labelText: widget.label!),
          ),
        ),
        SizedBox(
          height: 15,
        )
      ],
    ));
  }
}
