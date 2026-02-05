# Cobol Archetype Demo (Wynxx Codegen Agent)

This folder contains a small COBOL sample used as an archetype repository:
- MPBALQRY.cbl  : COBOL program sample (DB2 cursor style)
- CPYBALIO.cpy  : input/output record layouts
- CPYBALHV.cpy  : host variables copybook
- MPBALRUN.jcl  : sample JCL to run the program

## How to use as a local archetype repo (WSL / Docker)

1) Copy this folder into your Wynxx-Transform repo:
   Wynxx-Transform/repositories/cobol-archetype-demo/

2) Initialize a local git repo (required because codegen clones from a repo URL):
   cd Wynxx-Transform/repositories/cobol-archetype-demo
   git init
   git add .
   git commit -m "Initial cobol archetype demo"

3) Register archetype in Codegen Agent using a file:// URL that is visible inside the container.
   Because docker-compose mounts ./repositories -> /repo/repositories (read-only),
   use this URL:
     file:///repo/repositories/cobol-archetype-demo

   Example POST /api/v1/archetypes:
   {
     "name": "Cobol Demo Archetype",
     "repository_url": "file:///repo/repositories/cobol-archetype-demo",
     "branch": "main",
     "base_language": "cobol",
     "tags": ["cobol","demo"],
     "type": "backend"
   }

Notes:
- If your default branch is 'master', set "branch": "master" when registering.
- This is a minimal repo. Real archetypes usually contain templates and placeholders.
