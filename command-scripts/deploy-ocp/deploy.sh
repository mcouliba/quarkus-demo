######################################
# Application Configuration Solution #
######################################

DIRECTORY=`dirname $0`

oc new-project quarkus-demo 2> /dev/null

oc project quarkus-demo
if [ $? -eq 0 ]
then
    oc policy add-role-to-user view -z default

    oc new-app mariadb-ephemeral \
        --param=DATABASE_SERVICE_NAME=inventory-mariadb \
        --param=MYSQL_DATABASE=inventorydb \
        --param=MYSQL_USER=inventory \
        --param=MYSQL_PASSWORD=inventory \
        --param=MYSQL_ROOT_PASSWORD=inventoryadmin \
        --labels=app=coolstore,app.kubernetes.io/instance=inventory-mariadb,app.kubernetes.io/name=mariadb,app.kubernetes.io/part-of=coolstore


    # Deploy INVENTORY QUARKUS
    cp $DIRECTORY/pom.xml $DIRECTORY/../../../inventory-quarkus
    cp $DIRECTORY/application.properties $DIRECTORY/../../../inventory-quarkus/src/main/resources
    mvn clean package -DskipTests

    oc new-app openjdk-11-rhel7:1.0 \
        --binary \
        --name=inventory-quarkus \
        --labels=app=coolstore,app.kubernetes.io/instance=inventory-quarkus,app.kubernetes.io/name=java,app.kubernetes.io/part-of=coolstore

    oc start-build inventory-quarkus --from-file $DIRECTORY/../../../inventory-quarkus/target/*-runner.jar --follow ;
    oc expose svc inventory-quarkus 

    # Deploy INVENTORY SPRING BOOT
    oc new-app registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.5 \
        --binary \
        --name=inventory-spring-boot \
        --labels=app=coolstore,app.kubernetes.io/instance=inventory-spring-boot,app.kubernetes.io/name=java,app.kubernetes.io/part-of=coolstore

    oc start-build inventory-spring-boot --from-dir $DIRECTORY/../../inventory-spring-boot --follow ;
    oc expose svc inventory-spring-boot 

    # Deploy INVENTORY QUARKUS NATIVE
    oc new-app quay.io/quarkus/ubi-quarkus-native-s2i:19.3.1-java11 \
        --binary \
        --name=inventory-native \
        --labels=app=coolstore,app.kubernetes.io/instance=inventory-native,app.kubernetes.io/name=java,app.kubernetes.io/part-of=coolstore
    oc patch bc/inventory-native -p '{"spec":{"resources":{"limits":{"cpu":"4", "memory":"8Gi"}}}}'
    rm -rf  $DIRECTORY/../../../inventory-quarkus/target
    oc start-build inventory-native --from-dir $DIRECTORY/../../inventory-native --follow ;

    # Annotations
    oc annotate --overwrite dc/inventory-quarkus app.openshift.io/connects-to='inventory-mariadb'
    oc annotate --overwrite dc/inventory-spring-boot app.openshift.io/connects-to='inventory-mariadb'
    oc annotate --overwrite dc/inventory-native app.openshift.io/connects-to='inventory-mariadb'
fi