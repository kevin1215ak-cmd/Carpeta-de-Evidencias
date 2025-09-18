% ========================
%  TRIAJE RESPIRATORIO
%  (reglas deterministas)
% ========================

% ---- Hechos de pacientes (ejemplo) ----
sintoma(juan, fiebre).
sintoma(juan, tos).
sintoma(juan, dolor_muscular).

sintoma(maria, estornudos).
sintoma(maria, congestion).
sintoma(maria, picazon_ojos).

sintoma(pedro, disnea_severa).    % alerta
sintoma(pedro, tos).

sintoma(lucia, fiebre).
sintoma(lucia, tos_seca).
sintoma(lucia, dolor_garganta).

edad(juan, 32).
edad(maria, 27).
edad(pedro, 71).
edad(lucia, 45).

comorbilidad(pedro, epoc).

% ---- 1) ALERTAS (cortan la decisión) ----
alerta_sintoma(disnea_severa).
alerta_sintoma(dolor_toracico).
alerta_sintoma(sat_oxigeno_baja).

tiene(P, S) :- sintoma(P, S).

detectar_alerta(P, S) :-
    alerta_sintoma(S),
    tiene(P, S), !.             % ¡corte!: si hay alerta, se termina el flujo

% ---- 2) VULNERABILIDAD ----
vulnerable(P) :-
    edad(P, E), E >= 65, !.
vulnerable(P) :-
    comorbilidad(P, _).

% ---- 3) CLASIFICACIÓN (conteo simple) ----
requisito(gripe, fiebre).
requisito(gripe, tos).
requisito(gripe, dolor_muscular).

requisito(resfriado, congestion).
requisito(resfriado, estornudos).
requisito(resfriado, tos).

requisito(covid, fiebre).
requisito(covid, tos_seca).
requisito(covid, dolor_garganta).

requisito(alergia, congestion).
requisito(alergia, estornudos).
requisito(alergia, picazon_ojos).

contraindica(alergia, fiebre).

puntaje(P, Dx, N) :-
    findall(S, (requisito(Dx, S), tiene(P, S)), A), length(A, A1),
    findall(S, (contraindica(Dx, S), tiene(P, S)), C), length(C, C1),
    N is A1 - C1.

diagnostico(P, Dx, N) :- puntaje(P, Dx, N), N > 0.

max_puntaje(P, Max) :-
    findall(N, diagnostico(P, _, N), Ns),
    Ns \= [], max_list(Ns, Max).

mejores_dx(P, Dxs) :-
    max_puntaje(P, M),
    findall(Dx, diagnostico(P, Dx, M), Dxs).

% ---- 4) PLAN ----
plan_para(urgente(_), derivar_urgencias).
plan_para(probable(alergia), antihistaminico).
plan_para(probable(resfriado), reposo_hidratacion).
plan_para(probable(gripe), aines_reposo).
plan_para(probable(covid), test_covid_aislamiento).

% Afecta plan si es vulnerable
ajustar_por_vulnerable(Plan, true, control_48h(Plan)).
ajustar_por_vulnerable(Plan, false, Plan).

% ---- Orquestador: secuencia de ideas ----
evaluar_paciente(P, reporte{
    riesgo: Riesgo,
    diagnosticos: DxList,
    plan: PlanAjustado,
    notas: Notas
}) :-
    (   detectar_alerta(P, S) ->
        Riesgo = urgente,
        DxList = [],
        plan_para(urgente(S), Plan),
        ajustar_por_vulnerable(Plan, false, PlanAjustado),
        Notas = [alerta(S), "derivar de inmediato"]
    ;   Riesgo = no_urgente,
        (vulnerable(P) -> Vul = true ; Vul = false),
        ( mejores_dx(P, Dxs) -> DxList = Dxs ; DxList = [] ),
        decidir_plan(DxList, Vul, PlanAjustado, Notas)
    ).

decidir_plan([Dx], Vul, PlanAjustado, [diagnostico_unico(Dx)]) :-
    plan_para(probable(Dx), Plan),
    ajustar_por_vulnerable(Plan, Vul, PlanAjustado), !.

decidir_plan([Dx1, Dx2 | _], Vul, PlanAjustado, [diagnostico_ambiguo([Dx1, Dx2])]) :-
    % si hay empate, elige uno neutral: test si incluye covid, si no, manejo sintomático
    (   member(covid, [Dx1, Dx2])
    ->  plan_para(probable(covid), Base)
    ;   Base = reposo_hidratacion),
    ajustar_por_vulnerable(Base, Vul, PlanAjustado), !.

decidir_plan([], _, sin_datos, ["no hay suficientes sintomas"]).
