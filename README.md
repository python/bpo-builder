About
------
This repository contains the code allowing to deploy http://bugs.python.org
on [OpenShift](https://www.openshift.org/).


Usage
-----
1. Download latest [OpenShift client](https://github.com/openshift/origin/releases)
  and run `oc cluster up` to setup a local cluster.  If you encounter any problems
  follow the diagnostic messages that appear on the screen, it is probably missing
  packages (eg. docker) or necessary configuration changes.

2. Instantiate a postgresql instance.  Depending on your needs there are two possibilies
  here. You can either proceed with a single development instance (A) or a full HA
  production one (B).

    A. To deploy single development instance you can either use the web console or
    the following command.  With the former make sure to use the exact same values
    as below command.

    ```
    oc new-app postgresql:9.5 \
        --name=bpo-db \
        --labels=app=bugs.python.org \
        --env=POSTGRESQL_USER=roundup \
        --env=POSTGRESQL_PASSWORD=roundup \
        --env=POSTGRESQL_DATABASE=roundup
    ```

    This will create the following resources:
    - [Deployment Configuration](https://docs.openshift.org/latest/dev_guide/deployments/how_deployments_work.html)
    - [Service](https://docs.openshift.org/latest/architecture/core_concepts/pods_and_services.html#services)

    This deployment configuration will kick of an actual deployment of our postgresql
    instance which leads to creating a [Replication Controller](https://docs.openshift.org/latest/architecture/core_concepts/deployments.html#replication-controllers)
    and a [Pod](https://docs.openshift.org/latest/architecture/core_concepts/pods_and_services.html#pods).

    **NOTE:** This setup uses an ephemeral storage, if you want to save your data you
    should read about [Persistence Volumes](https://docs.openshift.org/latest/dev_guide/persistent_volumes.html).

    When the postgresql instance is up we need to drop the database and allow roundup
    initialize it from scratch.  To do so invoke the following commands, which will
    get you connected to bpo-db pod and drop the database and add necessary access
    rights to create a new one, instead:

    ```
    oc rsh $(oc get pod -l deploymentconfig=bpo-db -o jsonpath='{.items[*].metadata.name}')
    # psql
    # drop database roundup;
    # alter user roundup createdb;
    ```

    B. To deploy full HA PostgreSQL using [patroni project](https://github.com/zalando/patroni/)
    invoke the following command:

    ```
    oc create -f \
      https://raw.githubusercontent.com/python/bpo-builder/master/template_patroni.yaml
    ```

    This will create the following resources:
    - [Stateful Set](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/)
    - [Services](https://docs.openshift.org/latest/architecture/core_concepts/pods_and_services.html#services)
    - [Service Account](https://docs.openshift.org/latest/dev_guide/service_accounts.html)
    - [Role and RoleBinding](https://kubernetes.io/docs/admin/authorization/rbac/)

    **NOTE:** You should copy the above template file and change `superuser-password`
    and `replication-password`.  These are `base64` encoded passwords.

    When the postgresql instance is up we need to create user roundup with appropriate
    password and add it rights to create a database.

    ```
    oc rsh patroni-0
    # psql -U postgres
    # create user roundup with createdb encrypted password 'changeme';
    ```

3. Now it is time to prepare all the bits necessary to deploy bugs.python.org itself:

  ```
  oc create -f \
    https://raw.githubusercontent.com/python/bpo-builder/master/template_bpo.yaml
  ```

  This will create the following resources:
  - [Build Configuration](https://docs.openshift.org/latest/dev_guide/builds/index.html)
  - [Image Stream](https://docs.openshift.org/latest/dev_guide/managing_images.html)
  - [Deployment Configuration](https://docs.openshift.org/latest/dev_guide/deployments/how_deployments_work.html)
  - [Service](https://docs.openshift.org/latest/architecture/core_concepts/pods_and_services.html#services)
  - [Route](https://docs.openshift.org/latest/dev_guide/routes.html)

  **NOTE:** This needs to be performed only when you're using a temporary database.

  Since we need to initiate the database only once, we need to set an environment
  variable (`INIT_DATABASE`), to tell the `run` script to do it:

  ```
  oc set env deploymentconfig/bpo INIT_DATABASE=true
  ```

  After the initial rollout this value should be cleared out:

  ```
  oc set env deploymentconfig/bpo INIT_DATABASE-
  ```

4. Edit `config/roundup.ini` and change the line:

  ```
  web = http://localhost:9999/python-dev/
  ```

  So that it matches the route the app will be exposed under.  You can easily check
  that with `oc get route/bpo`.  Afterwards you can create the necessary configuration:

  ```
  oc create secret generic config \
      --from-file=roundup=config/roundup.ini \
      --from-file=detectors=config/detectors.ini
  ```

5. With all the pieces in place we can finally start the application.  To do so
  we need to build the actual image that will serve bugs.python.org:

  ```
  oc start-build bpo
  ```
