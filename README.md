In order to run the project, you need to have the following dependencies installed:
- Docker
- Docker Compose

1. Set up environment variables:
   - MYSQL_ROOT_PASSWORD
   - DB_NAME
   - DB_USERNAME
   - DB_PASSWORD

_Example:_
`export MYSQL_ROOT_PASSWORD=myextremelysecurepassword`


2. Clone source code from this repository


3. Open directory with the source code:
   `cd boanerges-frontend`


4. Run the project: `docker compose up`


5. Open http://localhost URL in your browser.


6. To stop the project, press `Ctrl + C` and run the following command: `docker compose down`

_Note:_ Repository with backend source code: [lerkasan/boanerges-backend](https://github.com/lerkasan/boanerges-backend)