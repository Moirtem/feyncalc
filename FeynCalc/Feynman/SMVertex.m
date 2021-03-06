(* ::Package:: *)

(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* :Title: SMVertex											*)

(*
	This software is covered by the GNU General Public License 3.
	Copyright (C) 1990-2018 Rolf Mertig
	Copyright (C) 1997-2018 Frederik Orellana
	Copyright (C) 2014-2018 Vladyslav Shtabovenko
*)

(* :Summary: Some Standard model vertices									*)

(* ------------------------------------------------------------------------ *)

SMVertex::usage =
"is a library of SM vertices. Currently it implements only few vertices and \
is not really useful.";

(* ------------------------------------------------------------------------ *)

Begin["`Package`"]
End[]

Begin["`SMVertex`Private`"]

Options[SMVertex] = {
	Dimension -> 4,
	Explicit -> True
};

l[w_Integer]:=
	FCGV["li"<>ToString[w]];

(*TODO Add all the SM vertices from Boehm and Denner *)

SMVertex[x___, i_Integer, y___] :=
	SMVertex[x, l[i], y];


SMVertex["AWW", mom1_, li1_, mom2_, li2_, mom3_, li3_, OptionsPattern[]] :=
	Block[	{dim, res},
		res = ChangeDimension[
			-I*SMP["e"]*( MetricTensor[li1, li2] * FourVector[(mom2 -mom1 ),li3]+
					MetricTensor[li2, li3] * FourVector[(mom3 -mom2 ),li1]+
					MetricTensor[li3, li1] * FourVector[(mom1 -mom3 ),li2]), OptionValue[Dimension]];
		res
	]/; OptionValue[Explicit];


(* directly from the SM.model file from FeynArts1.0 *)
SMVertex["HHH", OptionsPattern[]] :=
	((-3*I)/2*SMP["e"]*SMP["m_H"]^2)/(SMP["m_W"]*SMP["sin_W"])

SMVertex["eeH", OptionsPattern[]] :=
	-((I*SMP["e"]*SMP["m_e"])/(2*SMP["m_W"]*SMP["sin_W"]))


FCPrint[1,"SMVertex.m loaded."];
End[]
