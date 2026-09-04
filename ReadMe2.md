# Local Build( On Your Laptop)
1. **SETUP AND DEPENDENCIES INSTALL**
Install nodejs and npm
Clone the code from the github to local
cd into project folder
Install dependencies from project root  , it will read package.json file and safely downloads all the required external libraries into a node_modules folder: run
```
# npm install 
```

2.  **Configure Environment Variables**
Most modern backends rely on private configuration files to run locally without exposing secrets.
Create a file named .env in the root directory.
Add your local configuration values (like your development port or a local database link):

PORT=3000
NODE_ENV=development
DATABASE_URL=mongodb://localhost:27017/my_local_db

3.  **Run the Application Locally**
Prior to running the application server there are certain scripts in package.json which you may have to run, e.g. npm run build….npm run start …these scripts do not rewrite your code or alter the actual features of your application. They simply change how your code is executed, where files are moved, and what security layers are applied.

```bash
#node src/index.js    or node dist/src/index.js
```

(This index.js file is at either at root or in src/ or at project root  check package.json file                           "start": "node src/index.js", this field  in scripts tells us where is index.js 

# How to Verify It's Working Locally
Once your terminal shows that the server is running, open your web browser or an API testing tool (like Postman) and navigate to your local host address:run
```
http://localhost:3000
```

# DOCKERIZE THE APP
1.  **WRITE THE DOCKERFILE** For writing any dockerfile we will need 
* **File stacks:** code for application
* **Prerequisites** tools,command to build 
* **Artifact** POST where is runnable file
* **APP RUN** :Command to run the app server
```
# Stage 1: Build the application
FROM node:20 AS builder
WORKDIR /app

# 1. Optimize caching: Copy package files first so npm install doesn't re-run 
# unless your dependencies actually change.
COPY package*.json ./
RUN npm install

# 2. Copy the rest of your source code and build the app
COPY . .

RUN npm run build
# In your builder stage, you run npm install. 
# This downloads both production dependencies (like express) and development 
# Tools (like nodemon and rimraf).
# If we copy that raw node_modules folder directly over to the final runner, 
# We are accidentally dragging along heavy development tools 
# That a live server doesn't need to run.
# So we delete these from node_modules after build is done at build stage end
RUN npm prune --production

# Stage 2: Run the application
FROM gcr.io/distroless/nodejs20-debian12 AS runner
WORKDIR /app

#Copy everything from the builder's dist directory to the runner's app directory
COPY --from=builder /app/dist .
COPY --from=builder /app/node_modules ./node_modules

# 6. Execute the entry point file from /app/src/index.js
# Node.js will automatically look up one level to find /app/node_modules
CMD ["src/index.js"]

# Distroless images are stripped-down, highly secure base images that do not contain a shell (like bash or sh) 
# or standard system tools. Instead, they are pre-configured to automatically use a specific language binary as the # "entry point".
# Here is exactly why CMD ["src/index.js"] works without typing node:1. 
#The Image Already Knows to
# Use NodeThe Distroless Node image has an invisible ENTRYPOINT pre-programmed into it that points directly to the # node binary.When you write CMD ["src/index.js"], Docker appends your command to that entry point behind the  #scenes.The system evaluates it exactly as if you ran: /nodejs/bin/node src/index.js.2. If you added "node", it #would breakIf you wrote CMD ["node", "src/index.js"], the container would see the pre-programmed entry point and #attempt to execute:bash/nodejs/bin/node node src/index.js
```

2.  **Build Docker image**
```
docker build -t <dockerhubusername>/<imagename>:<tag>
```
3.  **Verify image**
Run container from this image and access it on browser
```
docker run -d -p 18000:18000 awajid3/nodejs_app:v1
http://localhost:18000
```

# Push the image to Docker hub
* **docker login**
```
docker login -u <username>
<enter your dockerhub PAT>
```
* **Push to dockerhub or any ECR **
```
docker push <dockerhubusername/imagename:tag>

```
# RUN on K8s cluster(Local Cluster Minikube)

1.  **create deployment.yaml, service.yaml file**

2.  **On your cluster run these conf file**

``` 
kubetcl apply -f k8s/deployement.yaml
kubectl apply -f k8s/service.yaml
```
3.  **verify**
```
kubectl port-forward svc/nodejs-app-service 8001:80
```
4.  **Acess it from the browser on**
```
localhost:8001
```
5.  **Access From outside the cluster with Hostname**
*  **create ingress.yaml file**
*  ** apply that file
```
kubectl apply -f k8s/ingress.yaml
```
*  **Map the Host Domain in your Windows Hosts File** make this entry and save
*  **C:\Windows\System32\drivers\etc\hosts**
```
127.0.0.1 nodejs-app.local
```
* **port forward** the  ingress controller from ingress-nginx namespace, Because it is our only entry get now so we will access it from outside cluster
```
kubectl port-forward svc/ingress-nginx-controller 8001:80 -n ingress-nginx
```
*  ** Verify**
```
http://nodes-app.local:8001
```
# Convert the app to helm package
* At root of project directory create helm chart folder # helm create < helm >
* it will create values.yaml file, template folder, and chart.yaml file
*  copied the k8s yaml file(deplyment.yaml, service.yaml, ingress.yaml) to cleaned helm/template folder.
* in values.yaml file defined the variables value like image tag for deployemnt yaml file.
* Remove all existing resource from cluster
* create resources (pod, service, ingress) using helm # helm install dev .(. is the path to chart.yaml file)
* use this command to check what manifest helm is using to create resources(pod,ingress, service)helm template dev helm/springboot_app_chart/
* Port forward the ingress-controller 
```
kubectl port-forward svc/ingress-nginx-controller 8001:80 -n ingress-nginx
```
* Verify
```
http://nodes-app.local:8001
```




