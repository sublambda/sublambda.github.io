// File generated by Gambit v4.9.5
// Link info: (409005 (js ((compactness 9))) "gambit/unstable" (("gambit/unstable")) (module_register returnpt_init ctrlpt_init parententrypt_init bignum cons peps flonump flonumbox r4 make_interned_symbol glo poll jsnumberp f64vector box stack sp r2 r3 absent_obj r0 r1 wrong_nargs nargs) (##fail-check-boolean ##fail-check-exact-integer ##exact-int.* ##exact-int.expt ##fail-check-nonnegative-exact-integer) (##make-inexact-real make-inexact-real gambit/unstable#) () #f)

_cst0__gambit_2f_unstable = new _F64Vector(new Float64Array([1.0,10.0,100.0,1000.0,10000.0,100000.0,1000000.0,10000000.0,100000000.0,1000000000.0,1e10,1e11,1e12,1e13,1e14,1e15,1e16,1e17,1e18,1e19,1e20,1e21,1e22]));

_cst1__gambit_2f_unstable = _i("##exact-int.expt");

_cst2__gambit_2f_unstable = _i("##exact-int.*");

_cst3__gambit_2f_unstable = _i("##exact->inexact");

_cst4__gambit_2f_unstable = _X(1,_i("negative?"));

_cst6__gambit_2f_unstable = _i("##fail-check-boolean");

_cst7__gambit_2f_unstable = _X(2,_i("mantissa"));

_cst9__gambit_2f_unstable = _i("##fail-check-nonnegative-exact-integer");

_cst10__gambit_2f_unstable = _i("##negative?");

_cst11__gambit_2f_unstable = _X(3,_i("exponent"));

_cst13__gambit_2f_unstable = _i("##fail-check-exact-integer");

_m(_bb1_gambit_2f_unstable_23_ = () => {
if (_n !== 0) {
return _w(_bb1_gambit_2f_unstable_23_);
}
_a = void 0;
return _r;
},-1,_i("gambit/unstable#"),!1,!0);



_m(_bb1__23__23_make_2d_inexact_2d_real = () => {
if (_n === 2) {
_s[++_t] = _a;
_a = _b;
_b = _absent_obj;
_c = _absent_obj;
} else {
if (_n === 3) {
_s[++_t] = _a;
_a = _b;
_b = _c;
_c = _absent_obj;
} else {
if (_n !== 4) {
return _w(_bb1__23__23_make_2d_inexact_2d_real);
}
}
}
if (_b === _absent_obj) {
return _bb2__23__23_make_2d_inexact_2d_real();
} else {
return _bb3__23__23_make_2d_inexact_2d_real();
}
},-1,_i("##make-inexact-real"),!1,!0);

_j(_bb2__23__23_make_2d_inexact_2d_real = () => {
_b = 0;
if (_c === _absent_obj) {
return _bb4__23__23_make_2d_inexact_2d_real();
} else {
return _bb4__23__23_make_2d_inexact_2d_real();
}
});

_j(_bb3__23__23_make_2d_inexact_2d_real = () => {
if (_c === _absent_obj) {
return _bb4__23__23_make_2d_inexact_2d_real();
} else {
return _bb4__23__23_make_2d_inexact_2d_real();
}
});

_j(_bb4__23__23_make_2d_inexact_2d_real = () => {
_c = new _Box(void 0);
_c.a = _cst0__gambit_2f_unstable;
if (_y(_a)) {
return _bb5__23__23_make_2d_inexact_2d_real();
} else {
return _bb17__23__23_make_2d_inexact_2d_real();
}
});

_j(_bb5__23__23_make_2d_inexact_2d_real = () => {
return _bb6__23__23_make_2d_inexact_2d_real();
});

_j(_bb17__23__23_make_2d_inexact_2d_real = () => {
_s[_t+1] = _r;
_s[_t+2] = _a;
_a = 10;
_t += 2;
return _p(_bb18__23__23_make_2d_inexact_2d_real);
});

_j(_bb6__23__23_make_2d_inexact_2d_real = () => {
if (_y(_b)) {
return _bb7__23__23_make_2d_inexact_2d_real();
} else {
return _bb17__23__23_make_2d_inexact_2d_real();
}
});

_j(_bb18__23__23_make_2d_inexact_2d_real = () => {
_r = _bb19__23__23_make_2d_inexact_2d_real;
_n = 2;
return _g["##exact-int.expt"]();
});

_j(_bb7__23__23_make_2d_inexact_2d_real = () => {
_d = _c.a;
_d = _d.a.length;
_s[_t+1] = - _b;
if (_s[_t+1] < _d) {
++_t;
return _bb8__23__23_make_2d_inexact_2d_real();
} else {
++_t;
return _bb16__23__23_make_2d_inexact_2d_real();
}
});

_k(_bb19__23__23_make_2d_inexact_2d_real = () => {
_b = _a;
_a = _s[_t];
_r = _bb20__23__23_make_2d_inexact_2d_real;
_n = 2;
--_t;
return _g["##exact-int.*"]();
},3,2);

_j(_bb8__23__23_make_2d_inexact_2d_real = () => {
_d = _c.a;
_d = _d.a.length;
if (_b < _d) {
return _bb9__23__23_make_2d_inexact_2d_real();
} else {
return _bb16__23__23_make_2d_inexact_2d_real();
}
});

_j(_bb16__23__23_make_2d_inexact_2d_real = () => {
--_t;
return _bb17__23__23_make_2d_inexact_2d_real();
});

_k(_bb20__23__23_make_2d_inexact_2d_real = () => {
if (_y(_a)) {
return _bb21__23__23_make_2d_inexact_2d_real();
} else {
return _bb22__23__23_make_2d_inexact_2d_real();
}
},2,2);

_j(_bb9__23__23_make_2d_inexact_2d_real = () => {
if (_b < 0) {
return _bb10__23__23_make_2d_inexact_2d_real();
} else {
return _bb15__23__23_make_2d_inexact_2d_real();
}
});

_j(_bb21__23__23_make_2d_inexact_2d_real = () => {
_a = _F(_a);
return _bb13__23__23_make_2d_inexact_2d_real();
});

_j(_bb22__23__23_make_2d_inexact_2d_real = () => {
if (_f(_a)) {
return _bb13__23__23_make_2d_inexact_2d_real();
} else {
return _bb23__23__23_make_2d_inexact_2d_real();
}
});

_j(_bb10__23__23_make_2d_inexact_2d_real = () => {
_b = - _b;
_c = _c.a;
_b = _F(_c.a[_b]);
_a = _F(_a);
_a = _F(_a.a / _b.a);
if (!(_s[_t-1] === !1)) {
return _bb11__23__23_make_2d_inexact_2d_real();
} else {
return _bb14__23__23_make_2d_inexact_2d_real();
}
});

_j(_bb15__23__23_make_2d_inexact_2d_real = () => {
_c = _c.a;
_b = _F(_c.a[_b]);
_a = _F(_a);
_a = _F(_a.a * _b.a);
if (!(_s[_t-1] === !1)) {
return _bb11__23__23_make_2d_inexact_2d_real();
} else {
return _bb14__23__23_make_2d_inexact_2d_real();
}
});

_j(_bb13__23__23_make_2d_inexact_2d_real = () => {
_r = _s[_t];
if (!(_s[_t-1] === !1)) {
return _bb11__23__23_make_2d_inexact_2d_real();
} else {
return _bb14__23__23_make_2d_inexact_2d_real();
}
});

_j(_bb23__23__23_make_2d_inexact_2d_real = () => {
_r = _bb12__23__23_make_2d_inexact_2d_real;
_n = 1;
return _e["##exact->inexact"]();
});

_j(_bb11__23__23_make_2d_inexact_2d_real = () => {
_a = ((_a.a < 0.0) || (1.0 / _a.a < 0.0)) === ((-1.0 < 0.0) || (1.0 / -1.0 < 0.0)) ? _a : _F(- _a.a);
_t -= 2;
return _r;
});

_j(_bb14__23__23_make_2d_inexact_2d_real = () => {
_t -= 2;
return _r;
});

_k(_bb12__23__23_make_2d_inexact_2d_real = () => {
return _bb13__23__23_make_2d_inexact_2d_real();
},2,2);



_m(_bb1_make_2d_inexact_2d_real = () => {
if (_n === 2) {
_s[++_t] = _a;
_a = _b;
_b = _absent_obj;
_c = _absent_obj;
} else {
if (_n === 3) {
_s[++_t] = _a;
_a = _b;
_b = _c;
_c = _absent_obj;
} else {
if (_n !== 4) {
return _w(_bb1_make_2d_inexact_2d_real);
}
}
}
if (typeof _s[_t] === "boolean") {
return _bb2_make_2d_inexact_2d_real();
} else {
return _bb24_make_2d_inexact_2d_real();
}
},-1,_i("make-inexact-real"),!1,!0);

_j(_bb2_make_2d_inexact_2d_real = () => {
if (_y(_a)) {
return _bb5_make_2d_inexact_2d_real();
} else {
return _bb3_make_2d_inexact_2d_real();
}
});

_j(_bb24_make_2d_inexact_2d_real = () => {
_s[_t+1] = _s[_t];
_s[_t] = _cst4__gambit_2f_unstable;
_s[_t+2] = _s[_t+1];
_s[_t+1] = _bb1_make_2d_inexact_2d_real;
_t += 2;
return _p(_bb25_make_2d_inexact_2d_real);
});

_j(_bb5_make_2d_inexact_2d_real = () => {
if (_a < 0) {
return _bb6_make_2d_inexact_2d_real();
} else {
return _bb10_make_2d_inexact_2d_real();
}
});

_j(_bb3_make_2d_inexact_2d_real = () => {
if (_a instanceof _Bignum) {
return _bb4_make_2d_inexact_2d_real();
} else {
return _bb6_make_2d_inexact_2d_real();
}
});

_j(_bb25_make_2d_inexact_2d_real = () => {
_n = 6;
return _g["##fail-check-boolean"]();
});

_j(_bb6_make_2d_inexact_2d_real = () => {
_s[_t+1] = _s[_t];
_s[_t] = _cst7__gambit_2f_unstable;
_s[_t+2] = _s[_t+1];
_s[_t+1] = _bb1_make_2d_inexact_2d_real;
_t += 2;
return _p(_bb7_make_2d_inexact_2d_real);
});

_j(_bb10_make_2d_inexact_2d_real = () => {
if (_b === _absent_obj) {
return _bb11_make_2d_inexact_2d_real();
} else {
return _bb18_make_2d_inexact_2d_real();
}
});

_j(_bb4_make_2d_inexact_2d_real = () => {
if (_y(_a)) {
return _bb5_make_2d_inexact_2d_real();
} else {
return _bb8_make_2d_inexact_2d_real();
}
});

_j(_bb7_make_2d_inexact_2d_real = () => {
_n = 6;
return _g["##fail-check-nonnegative-exact-integer"]();
});

_j(_bb11_make_2d_inexact_2d_real = () => {
_d = 0;
if (_y(_d)) {
return _bb12_make_2d_inexact_2d_real();
} else {
return _bb19_make_2d_inexact_2d_real();
}
});

_j(_bb18_make_2d_inexact_2d_real = () => {
_d = _b;
if (_y(_d)) {
return _bb12_make_2d_inexact_2d_real();
} else {
return _bb19_make_2d_inexact_2d_real();
}
});

_j(_bb8_make_2d_inexact_2d_real = () => {
if (_f(_a)) {
return _bb9_make_2d_inexact_2d_real();
} else {
return _bb23_make_2d_inexact_2d_real();
}
});

_j(_bb12_make_2d_inexact_2d_real = () => {
if (_c === _absent_obj) {
return _bb13_make_2d_inexact_2d_real();
} else {
return _bb15_make_2d_inexact_2d_real();
}
});

_j(_bb19_make_2d_inexact_2d_real = () => {
if (_d instanceof _Bignum) {
return _bb12_make_2d_inexact_2d_real();
} else {
return _bb20_make_2d_inexact_2d_real();
}
});

_j(_bb9_make_2d_inexact_2d_real = () => {
if (_a.a < 0.0) {
return _bb6_make_2d_inexact_2d_real();
} else {
return _bb10_make_2d_inexact_2d_real();
}
});

_j(_bb23_make_2d_inexact_2d_real = () => {
_s[_t+1] = _r;
_s[_t+2] = _a;
_s[_t+3] = _b;
_s[_t+4] = _c;
_r = _bb16_make_2d_inexact_2d_real;
_n = 1;
_t += 4;
return _e["##negative?"]();
});

_j(_bb13_make_2d_inexact_2d_real = () => {
_b = !1;
return _bb14_make_2d_inexact_2d_real();
});

_j(_bb15_make_2d_inexact_2d_real = () => {
_b = _c;
return _bb14_make_2d_inexact_2d_real();
});

_j(_bb20_make_2d_inexact_2d_real = () => {
_s[_t+1] = _s[_t];
_s[_t] = _cst11__gambit_2f_unstable;
_s[_t+2] = _s[_t+1];
_s[_t+1] = _bb1_make_2d_inexact_2d_real;
_t += 2;
return _p(_bb21_make_2d_inexact_2d_real);
});

_k(_bb16_make_2d_inexact_2d_real = () => {
if (!(_a === !1)) {
return _bb22_make_2d_inexact_2d_real();
} else {
return _bb17_make_2d_inexact_2d_real();
}
},5,2);

_j(_bb14_make_2d_inexact_2d_real = () => {
_c = _b;
_b = _d;
_n = 4;
return _p(_bb1__23__23_make_2d_inexact_2d_real);
});

_j(_bb21_make_2d_inexact_2d_real = () => {
_n = 6;
return _g["##fail-check-exact-integer"]();
});

_j(_bb22_make_2d_inexact_2d_real = () => {
_c = _s[_t];
_b = _s[_t-1];
_a = _s[_t-2];
_r = _s[_t-3];
_t -= 4;
return _bb6_make_2d_inexact_2d_real();
});

_j(_bb17_make_2d_inexact_2d_real = () => {
_c = _s[_t];
_b = _s[_t-1];
_a = _s[_t-2];
_r = _s[_t-3];
if (_b === _absent_obj) {
_t -= 4;
return _bb11_make_2d_inexact_2d_real();
} else {
_t -= 4;
return _bb18_make_2d_inexact_2d_real();
}
});



_module_register([[_i("gambit/unstable")],[],null,1,_bb1_gambit_2f_unstable_23_,!1]);

