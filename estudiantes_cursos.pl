% ----------------------------
% Base de conocimientos (hechos)
% ----------------------------

% Estudiantes
estudiante(juan).
estudiante(maria).
estudiante(pedro).
estudiante(laura).

% Cursos
curso(matematicas).
curso(fisica).
curso(programacion).
curso(literatura).

% Inscripciones (quién toma qué curso)
inscrito(juan, matematicas).
inscrito(juan, programacion).
inscrito(maria, fisica).
inscrito(maria, literatura).
inscrito(pedro, programacion).
inscrito(laura, matematicas).
inscrito(laura, literatura).

% ----------------------------
% Reglas (lógica)
% ----------------------------

% Regla 1: Verificar si un estudiante está en un curso.
% Uso: ?- esta_en(juan, matematicas). -> true.
esta_en(Estudiante, Curso) :-
    inscrito(Estudiante, Curso).

% Regla 2: Dos estudiantes son compañeros si están en el mismo curso.
% Uso: ?- son_companeros(juan, pedro). -> true (por programacion).
son_companeros(Estudiante1, Estudiante2) :-
    inscrito(Estudiante1, Curso),
    inscrito(Estudiante2, Curso),
    Estudiante1 \= Estudiante2.  % Evita que un estudiante sea compañero de sí mismo.

% Regla 3: Obtener todos los cursos de un estudiante.
% Uso: ?- cursos_de(juan, Cursos). -> Cursos = [matematicas, programacion].
cursos_de(Estudiante, Cursos) :-
    findall(Curso, inscrito(Estudiante, Curso), Cursos).

% ----------------------------
% Ejemplo de consultas
% ----------------------------
% ?- esta_en(laura, literatura).   % Verifica si Laura está en literatura.
% ?- son_companeros(maria, laura). % ¿María y Laura son compañeras?
% ?- cursos_de(juan, Cursos).      % Obtiene todos los cursos de Juan.