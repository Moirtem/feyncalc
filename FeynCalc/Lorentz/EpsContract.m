(* ::Package:: *)

(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* :Title: EpsContract														*)

(*
	This software is covered by the GNU General Public License 3.
	Copyright (C) 1990-2016 Rolf Mertig
	Copyright (C) 1997-2016 Frederik Orellana
	Copyright (C) 2014-2016 Vladyslav Shtabovenko
*)

(* :Summary: Contractions of two Eps tensors.								*)

(* ------------------------------------------------------------------------ *)


EpsContract::usage=
"EpsContract[expr] is a function that handles contractions of two Levi-Civita
tensors. It is also an option of Contract and other functions that specifies
whether such contractions should be done or not.";

EpsContract::fail=
"Error! EpsContract has encountered a fatal problem and must abort the computation. \
The problem reads: `1`";

(* ------------------------------------------------------------------------ *)

Begin["`Package`"]
End[]

Begin["`EpsContract`Private`"]

Options[EpsContract] = {
	FCI -> False,
	Collecting ->True,
	Factoring -> False
};

EpsContract[expr_, OptionsPattern[]]:=
	Block[{ex, tmp, res, epsList, epsListEval,repRule, epsHead,null1,null2},

		If[ !OptionValue[FCI],
			ex = FCI[expr],
			ex = expr
		];

		If[ FreeQ[ex,Eps],
			Return[ex]
		];

		If[	OptionValue[Collecting],
			ex = Collect2[ex,Eps,Factoring->OptionValue[Factoring]]
		];

		If[ Head[ex]===Plus,
			res = Map[(SelectFree[#, Eps] epsHead[SelectNotFree[#, Eps]]) &, ex],
			res = SelectFree[ex, Eps] epsHead[SelectNotFree[ex, Eps]]

		];

		If[ Together[(res /. epsHead -> Identity)-ex] =!= 0,
			Message[EpsContract::fail, "Failed to isolate epsilon tensors"];
			Abort[]
		];

		epsList = Cases[res+null1+null2, _epsHead, Infinity];

		epsListEval = epsCleverCon/@(epsList/. epsHead->Identity);

		repRule = MapThread[Rule[#1, #2] &, {epsList, epsListEval}];

		res = res/.repRule


	];

epsCleverCon[expr_]:=
	expr //. Power[Eps[a__],n_] :> epsHold[epscon[a]^n] //.
	Eps[a__] Eps[b__]/; Length[Intersection[{a},{b}]]===3 :> epsHold[epscon[a]epscon[b]] //.
	Eps[a__] Eps[b__]/; Length[Intersection[{a},{b}]]===2 :> epsHold[epscon[a]epscon[b]] //.
	Eps[a__] Eps[b__]/; Length[Intersection[{a},{b}]]===1 :> epsHold[epscon[a]epscon[b]] /.
	Eps -> epscon /. epscon -> Eps /. epsHold->Identity;

epscon/:
	epscon[a1_,a2_,a3_,a4_]^2 :=
		(( - ($LeviCivitaSign)^2 Det[{
			{PairContract[a1,a1],PairContract[a1,a2],PairContract[a1,a3],PairContract[a1,a4]},
			{PairContract[a2,a1],PairContract[a2,a2],PairContract[a2,a3],PairContract[a2,a4]},
			{PairContract[a3,a1],PairContract[a3,a2],PairContract[a3,a3],PairContract[a3,a4]},
			{PairContract[a4,a1],PairContract[a4,a2],PairContract[a4,a3],PairContract[a4,a4]}
		}])/.PairContract->Pair)/; MatchQ[DeleteDuplicates[Head/@{a1,a2,a3,a4}],{LorentzIndex}|{Momentum}|{LorentzIndex,Momentum}];

epscon/:
	epscon[a1_,a2_,a3_]^2 :=
		((( ($LeviCivitaSign)^2 Det[{
			{CPairContract[a1,a1],CPairContract[a1,a2],CPairContract[a1,a3]},
			{CPairContract[a2,a1],CPairContract[a2,a2],CPairContract[a2,a3]},
			{CPairContract[a3,a1],CPairContract[a3,a2],CPairContract[a3,a3]}
		}]//Expand)/.CPairContract->CPair ))/; MatchQ[DeleteDuplicates[Head/@{a1,a2,a3}],{CIndex}|{CMomentum}|{CIndex,CMomentum}];


epscon/:
	epscon[a1_,a2_,a3_,a4_]^n_Integer?Positive :=
		((hold[epscon[a1,a2,a3,a4]^2] epscon[a1,a2,a3,a4]^(n-2))/. hold->Identity )/; n>=3 && DeleteDuplicates[Head/@{a1,a2,a3,a4}]==={Momentum};

epscon/:
	epscon[a1_,a2_,a3_,a4_]^n_Integer?Positive :=
	(Message[EpsContract::fail,"Epsilon tensor to a power higher than two with uncontracted Lorentz indices violates Einsein summation convention!"]; Abort[])/; n>=3 && !FreeQ[{a1,a2,a3,a4},LorentzIndex];

epscon/:
	epscon[a1_,a2_,a3_,a4_] epscon[b1_,b2_,b3_,b4_] :=
		(( - ($LeviCivitaSign)^2 Det[{{PairContract[a1,b1],PairContract[a1,b2],PairContract[a1,b3],PairContract[a1,b4]},
		{PairContract[a2,b1],PairContract[a2,b2],PairContract[a2,b3],PairContract[a2,b4]},
		{PairContract[a3,b1],PairContract[a3,b2],PairContract[a3,b3],PairContract[a3,b4]},
		{PairContract[a4,b1],PairContract[a4,b2],PairContract[a4,b3],PairContract[a4,b4]}}]//Expand)/.PairContract->Pair)/; MatchQ[DeleteDuplicates[Head/@{a1,a2,a3,a4,b1,b2,b3,b4}],{LorentzIndex}|{Momentum}|{LorentzIndex,Momentum}];

epscon/:
	epscon[a1_,a2_,a3_] epscon[b1_,b2_,b3_] :=
		(( ($LeviCivitaSign)^2 Det[{{CPairContract[a1,b1],CPairContract[a1,b2],CPairContract[a1,b3]},
		{CPairContract[a2,b1],CPairContract[a2,b2],CPairContract[a2,b3]},
		{CPairContract[a3,b1],CPairContract[a3,b2],CPairContract[a3,b3]}}]//Expand)/.CPairContract->CPair)/; MatchQ[DeleteDuplicates[Head/@{a1,a2,a3,b1,b2,b3}],{CIndex}|{CMomentum}|{CIndex,CMomentum}];



FCPrint[1,"EpsContract.m loaded."];
End[]
