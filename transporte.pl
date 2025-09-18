% --- Hechos ---
distancia(casa, trabajo, corta).
distancia(casa, playa, larga).

clima(hoy, soleado).
clima(manana, lluvioso).

% --- Reglas de decisión ---
usar(bicicleta, Dist) :-
    Dist = corta.

usar(auto, Dist) :-
    Dist = larga.

usar(bus, Dist) :-
    Dist = larga.

% --- Regla que combina clima y distancia ---
transporte_recomendado(Lugar, Transporte) :-
    distancia(casa, Lugar, Dist),
    clima(hoy, Clima),
    decide_transporte(Dist, Clima, Transporte).

% Árbol de decisiones muy simple
decide_transporte(corta, soleado, bicicleta).
decide_transporte(corta, lluvioso, bus).
decide_transporte(larga, soleado, auto).
decide_transporte(larga, lluvioso, bus).
