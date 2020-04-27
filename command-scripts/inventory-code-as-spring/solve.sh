##########################
# gateway-vertx Solution #
##########################

DIRECTORY=`dirname $0`

#mkdir $DIRECTORY/../../inventory-quarkus
cp $DIRECTORY/pom.xml $DIRECTORY/../../../inventory-quarkus
rm -r $DIRECTORY/../../../inventory-quarkus/src
cp -R $DIRECTORY/src $DIRECTORY/../../../inventory-quarkus
