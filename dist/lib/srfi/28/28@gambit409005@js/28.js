// File generated by Gambit v4.9.5
// Link info: (409005 (js ((compactness 9))) "srfi/28" (("srfi/28")) (module_register returnpt_init ctrlpt_init parententrypt_init peps string base92_decode make_interned_char r4 make_interned_symbol glo r3 poll sp stack stringp build_rest r2 r0 r1 wrong_nargs nargs) (##write-substring ##get-output-string ##error ##fail-check-string ##open-output-string) (srfi/28# srfi/28#format) () #f)

_cst0__srfi_2f_28 = _i("##open-output-string");

_cst1__srfi_2f_28 = _i("##fail-check-string");

_cst2__srfi_2f_28 = _make_interned_char(126);

_cst3__srfi_2f_28 = _i("##get-output-string");

_cst4__srfi_2f_28 = _make_interned_char(97);

_cst5__srfi_2f_28 = new _ScmString(_z("c,cQcFcRcPcScOcHcWcHCcHcVcFcDcScHCcVcHcTcXcHcQcFcH"));

_cst6__srfi_2f_28 = _i("##write-substring");

_cst7__srfi_2f_28 = _make_interned_char(115);

_cst8__srfi_2f_28 = _i("##error");

_cst9__srfi_2f_28 = new _ScmString(_z("c1cRCcYcDcOcXcHCcIcRcUCcHcVcFcDcScHCcVcHcTcXcHcQcFcH"));

_cst10__srfi_2f_28 = _i("##display");

_cst11__srfi_2f_28 = _make_interned_char(37);

_cst12__srfi_2f_28 = new _ScmString(_z("c1cRCcYcDcOcXcHCcIcRcUCcHcVcFcDcScHCcVcHcTcXcHcQcFcH"));

_cst13__srfi_2f_28 = _i("##write");

_cst14__srfi_2f_28 = new _ScmString(_z("-"));

_cst15__srfi_2f_28 = new _ScmString(_z("ca"));

_cst16__srfi_2f_28 = new _ScmString(_z("c8cQcUcHcFcRcJcQcLc]cHcGCcHcVcFcDcScHCcVcHcTcXcHcQcFcH"));

_m(_bb1_srfi_2f_28_23_ = () => {
if (_n !== 0) {
return _w(_bb1_srfi_2f_28_23_);
}
_a = void 0;
return _r;
},-1,_i("srfi/28#"),!1,!0);



_m(_bb1_srfi_2f_28_23_format = () => {
if (_n === 1) {
_b = null;
} else {
if (!_build_rest(1)) {
return _w(_bb1_srfi_2f_28_23_format);
}
}
if (_stringp(_a)) {
return _bb2_srfi_2f_28_23_format();
} else {
return _bb35_srfi_2f_28_23_format();
}
},-1,_i("srfi/28#format"),!1,!0);

_j(_bb2_srfi_2f_28_23_format = () => {
_s[_t+1] = _r;
_s[_t+2] = _a;
_s[_t+3] = _b;
_t += 3;
return _p(_bb3_srfi_2f_28_23_format);
});

_j(_bb35_srfi_2f_28_23_format = () => {
_s[_t+1] = 1;
_s[_t+2] = null;
_c = _b;
_b = _a;
_a = _bb1_srfi_2f_28_23_format;
_t += 2;
return _p(_bb36_srfi_2f_28_23_format);
});

_j(_bb3_srfi_2f_28_23_format = () => {
_r = _bb4_srfi_2f_28_23_format;
_n = 0;
return _g["##open-output-string"]();
});

_j(_bb36_srfi_2f_28_23_format = () => {
_n = 5;
return _g["##fail-check-string"]();
});

_k(_bb4_srfi_2f_28_23_format = () => {
_s[_t+1] = _s[_t-2];
_s[_t-2] = _s[_t-1];
_c = _s[_t];
_b = 0;
_r = _s[_t+1];
_t -= 2;
return _p(_bb6_srfi_2f_28_23_format);
},3,1);

_j(_bb6_srfi_2f_28_23_format = () => {
_s[_t+1] = _a;
_s[_t+2] = _b;
_b = _c;
_c = _s[_t+2];
_a = _s[_t+2];
++_t;
return _p(_bb7_srfi_2f_28_23_format);
});

_j(_bb7_srfi_2f_28_23_format = () => {
_d = _s[_t-1].a.length;
if (_c < _d) {
return _bb8_srfi_2f_28_23_format();
} else {
return _bb32_srfi_2f_28_23_format();
}
});

_j(_bb8_srfi_2f_28_23_format = () => {
_d = _make_interned_char(_s[_t-1].a[_c]);
if (_d.a === 126) {
return _bb9_srfi_2f_28_23_format();
} else {
return _bb31_srfi_2f_28_23_format();
}
});

_j(_bb32_srfi_2f_28_23_format = () => {
_s[_t+1] = _r;
_s[_t+2] = _s[_t-1];
_b = _a;
_a = _s[_t];
_r = _bb33_srfi_2f_28_23_format;
_t += 2;
return _p(_bb10_srfi_2f_28_23_format);
});

_j(_bb9_srfi_2f_28_23_format = () => {
_s[_t+1] = _r;
_s[_t+2] = _b;
_s[_t+3] = _c;
_s[_t+4] = _s[_t-1];
_b = _a;
_a = _s[_t];
_r = _bb14_srfi_2f_28_23_format;
_t += 4;
return _p(_bb10_srfi_2f_28_23_format);
});

_j(_bb31_srfi_2f_28_23_format = () => {
_c = _c + 1;
return _p(_bb7_srfi_2f_28_23_format);
});

_j(_bb10_srfi_2f_28_23_format = () => {
if (_b < _c) {
return _bb11_srfi_2f_28_23_format();
} else {
return _bb13_srfi_2f_28_23_format();
}
});

_k(_bb33_srfi_2f_28_23_format = () => {
_a = _s[_t-1];
_r = _s[_t];
return _p(_bb34_srfi_2f_28_23_format);
},3,3);

_k(_bb14_srfi_2f_28_23_format = () => {
_a = _s[_t] + 1;
_b = _s[_t-4].a.length;
if (_a < _b) {
return _bb15_srfi_2f_28_23_format();
} else {
return _bb30_srfi_2f_28_23_format();
}
},5,3);

_j(_bb11_srfi_2f_28_23_format = () => {
_s[_t+1] = _c;
_c = _a;
_s[_t+2] = _b;
_b = _s[_t+1];
_a = _s[_t+2];
_t += 2;
return _p(_bb12_srfi_2f_28_23_format);
});

_j(_bb13_srfi_2f_28_23_format = () => {
_a = void 0;
--_t;
return _r;
});

_j(_bb34_srfi_2f_28_23_format = () => {
_n = 1;
_t -= 3;
return _g["##get-output-string"]();
});

_j(_bb15_srfi_2f_28_23_format = () => {
_b = _make_interned_char(_s[_t-4].a[_a]);
if (_b === _cst4__srfi_2f_28) {
return _bb16_srfi_2f_28_23_format();
} else {
return _bb18_srfi_2f_28_23_format();
}
});

_j(_bb30_srfi_2f_28_23_format = () => {
_a = _cst5__srfi_2f_28;
_r = _s[_t-2];
return _p(_bb22_srfi_2f_28_23_format);
});

_j(_bb12_srfi_2f_28_23_format = () => {
_n = 4;
_t -= 2;
return _g["##write-substring"]();
});

_j(_bb16_srfi_2f_28_23_format = () => {
if (_s[_t-1] === null) {
return _bb17_srfi_2f_28_23_format();
} else {
return _bb29_srfi_2f_28_23_format();
}
});

_j(_bb18_srfi_2f_28_23_format = () => {
if (_b === _cst7__srfi_2f_28) {
return _bb23_srfi_2f_28_23_format();
} else {
return _bb19_srfi_2f_28_23_format();
}
});

_j(_bb22_srfi_2f_28_23_format = () => {
_n = 1;
_t -= 5;
return _g["##error"]();
});

_j(_bb17_srfi_2f_28_23_format = () => {
_a = _cst9__srfi_2f_28;
_r = _s[_t-2];
return _p(_bb22_srfi_2f_28_23_format);
});

_j(_bb29_srfi_2f_28_23_format = () => {
_s[_t] = _a;
_b = _s[_t-3];
_a = _s[_t-1].a;
_r = _bb26_srfi_2f_28_23_format;
_n = 2;
return _e["##display"]();
});

_j(_bb23_srfi_2f_28_23_format = () => {
if (_s[_t-1] === null) {
return _bb24_srfi_2f_28_23_format();
} else {
return _bb25_srfi_2f_28_23_format();
}
});

_j(_bb19_srfi_2f_28_23_format = () => {
if (_b === _cst11__srfi_2f_28) {
return _bb27_srfi_2f_28_23_format();
} else {
return _bb20_srfi_2f_28_23_format();
}
});

_k(_bb26_srfi_2f_28_23_format = () => {
_c = _s[_t-1].b;
_b = _s[_t] + 1;
_a = _s[_t-3];
_r = _s[_t-2];
_t -= 4;
return _p(_bb6_srfi_2f_28_23_format);
},5,3);

_j(_bb24_srfi_2f_28_23_format = () => {
_a = _cst12__srfi_2f_28;
_r = _s[_t-2];
return _p(_bb22_srfi_2f_28_23_format);
});

_j(_bb25_srfi_2f_28_23_format = () => {
_s[_t] = _a;
_b = _s[_t-3];
_a = _s[_t-1].a;
_r = _bb26_srfi_2f_28_23_format;
_n = 2;
return _e["##write"]();
});

_j(_bb27_srfi_2f_28_23_format = () => {
_s[_t] = _a;
_b = _s[_t-3];
_a = _cst14__srfi_2f_28;
_r = _bb5_srfi_2f_28_23_format;
_n = 2;
return _e["##display"]();
});

_j(_bb20_srfi_2f_28_23_format = () => {
if (_b === _cst2__srfi_2f_28) {
return _bb28_srfi_2f_28_23_format();
} else {
return _bb21_srfi_2f_28_23_format();
}
});

_k(_bb5_srfi_2f_28_23_format = () => {
_c = _s[_t-1];
_b = _s[_t] + 1;
_a = _s[_t-3];
_r = _s[_t-2];
_t -= 4;
return _p(_bb6_srfi_2f_28_23_format);
},5,3);

_j(_bb28_srfi_2f_28_23_format = () => {
_s[_t] = _a;
_b = _s[_t-3];
_a = _cst15__srfi_2f_28;
_r = _bb5_srfi_2f_28_23_format;
_n = 2;
return _e["##display"]();
});

_j(_bb21_srfi_2f_28_23_format = () => {
_a = _cst16__srfi_2f_28;
_r = _s[_t-2];
return _p(_bb22_srfi_2f_28_23_format);
});



_module_register([[_i("srfi/28")],[],null,1,_bb1_srfi_2f_28_23_,!1]);

