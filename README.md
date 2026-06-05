# ⚔️ Rotina do Herói (Hero's Routine)

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![NodeJS](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)
![Prisma](https://img.shields.io/badge/Prisma-3982CE?style=for-the-badge&logo=Prisma&logoColor=white)

Transforme a sua vida real em um verdadeiro RPG! O **Rotina do Herói** é um aplicativo mobile e web de gerenciamento de tarefas gamificado, desenvolvido para ajudar os usuários a manterem a consistência e a disciplina através de mecânicas de jogos.

## 🎯 Sobre o Projeto

O objetivo do MVP do **Rotina do Herói** é acabar com a procrastinação recompensando o esforço diário. Ao completar missões e manter o hiperfoco, o usuário ganha pontos de experiência (XP), sobe de nível e evolui seus atributos, exatamente como em um jogo.

O sistema utiliza uma arquitetura separada com um frontend responsivo em Flutter e uma API RESTful segura construída em Node.js.

## ✨ Funcionalidades (Features)

* **Autenticação Segura:** Login, cadastro e recuperação de senha via email utilizando JWT e bcrypt.
* **Sistema de Missões:** Criação de tarefas com níveis de prioridade (Alta, Média, Baixa).
* **Atributos de RPG:** Evolua seu personagem completando tarefas específicas:
  * **Coragem (COR):** Concedido ao enfrentar as missões de Prioridade Alta.
  * **Vitalidade (VIT):** Recompensa o cuidado pessoal, como hidratação e pausas de descanso.
  * **Agilidade (AGI):** Ganhos através do foco contínuo.
* **Modo Hiperfoco:** Um timer embutido (estilo Pomodoro) para execução de tarefas sem distrações.
* **Multiplataforma:** Disponível como aplicativo nativo para Android (.apk/.aab) e Web via Firebase Hosting.

## 🛠️ Tecnologias Utilizadas

**Frontend (Mobile & Web)**
* Flutter & Dart
* Arquitetura baseada em `Services` para consumo de API
* Gerenciamento de estado e persistência com `SharedPreferences`

**Backend (API Rest)**
* Node.js com Express
* Prisma ORM (Banco de dados relacional)
* Sistema de envio de emails com Nodemailer
* Autenticação via JSON Web Token (JWT)
* Hospedagem na nuvem via Railway

## 🚀 Como Executar o Projeto Localmente

### Pré-requisitos
Certifique-se de ter instalado em sua máquina:
* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* [Git](https://git-scm.com/)

### Instalação (Frontend)

1. Clone este repositório:
   ```bash
   git clone [https://github.com/Rotina-do-heroi/APP.git](https://github.com/Rotina-do-heroi/APP.git)
