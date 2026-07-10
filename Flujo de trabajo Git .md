# Flujo de trabajo Git — Notebook / PC Escritorio

## Al empezar a trabajar (SIEMPRE primero)
```bash
git status          # ver si hay cambios pendientes antes de bajar nada
git pull             # traer los últimos cambios de GitHub
```

## Mientras trabajás (chequeo rápido)
```bash
git status           # qué cambió, qué está sin subir
git diff              # ver los cambios línea por línea (opcional)
```

## Al terminar de trabajar (SIEMPRE antes de cerrar)
```bash
git add .                          # agrega todos los cambios
git status                          # revisar qué se va a subir (en verde)
git commit -m "descripción breve"   # guarda el cambio localmente
git push                            # sube a GitHub
```

## Si algo salió mal / dudas

```bash
git log --oneline -5     # ver los últimos 5 commits
git remote -v              # confirmar que el repo apunta a GitHub por SSH
```

## Regla de oro
**Nunca cierres la PC sin hacer `push` si tocaste algo.**
Si te olvidás y te vas a la otra PC, vas a tener versiones divergentes y hay que resolver conflictos a mano.