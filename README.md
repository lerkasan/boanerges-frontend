In order to run the project, you need to have the following dependencies installed:
- Docker
- Docker Compose

1. Run the following command to build the frontend image:

`docker build -t lerkasan/boanerges-frontend:latest .`


2. Clone the following repository to get the backend source code:
   [lerkasan/boanerges-backend](https://github.com/lerkasan/boanerges-backend)


3. Change directory to the backend project and build the backend image according to the instructions in the backend repository:

`cd boanerges-backend`

Set up environment variables:
- MYSQL_ROOT_PASSWORD
- DB_NAME
- DB_USERNAME
- DB_PASSWORD

_Example:_
`export MYSQL_ROOT_PASSWORD=myextremelysecurepassword`

`docker build -t lerkasan/boanerges-backend:latest .`

4. Run the project:

`docker compose up`

5. Open http://localhost URL in your browser.


6. To stop the project, press `Ctrl + C` or run the following command:

`docker compose down`