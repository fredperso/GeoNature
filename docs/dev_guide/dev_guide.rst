====================================================
Aide mémoire pour l'utilisation du core de geonature
====================================================


Démarrage du serveur de dev backend
===================================

    ::

    (venv)...$ geonature dev_back


Base de données
===============

Session sqlalchemy
------------------

geonature.utils.env.DB
~~~~~~~~~~~~~~~~~~~~~~

Fournit l'instance de connexion SQLAlchemy


Python ::

    from geonature.utils.env import DB

    result = DB.session.query(MyModel).get(1)






Serialisation des modèles
=========================


geonature.utils.utilssqlalchemy.serializable
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Décorateur pour les modèles SQLA : Ajoute une méthode as_dict qui retourne un dictionnaire des données de l'objet sérialisable json


Fichier définition modèle ::

    from geonature.utils.env import DB
    from geonature.utils.utilssqlalchemy import serializable

    @serializable
    class MyModel(DB.Model):
        __tablename__ = 'bla'
        ...


fichier utilisation modele ::

    instance = DB.session.query(MyModel).get(1)
    result = instance.as_dict()



geonature.utils.utilssqlalchemy.geoserializable
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Décorateur pour les modèles SQLA : Ajoute une méthode as_geofeature qui retourne un dictionnaire serialisable sous forme de Feature geojson.


Fichier définition modèle ::

    from geonature.utils.env import DB
    from geonature.utils.utilssqlalchemy import geoserializable

    @geoserializable
    class MyModel(DB.Model):
        __tablename__ = 'bla'
        ...


fichier utilisation modele ::

    instance = DB.session.query(MyModel).get(1)
    result = instance.as_geofeature()



geonature.utils.utilssqlalchemy.json_resp
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Décorateur pour les routes : les données renvoyées par la route sont automatiquement serialisées en json (ou geojson selon la structure des données)

S'insère entre le décorateur de route flask et la signature de fonction


fichier routes ::

    from flask import Blueprint
    from geonature.utils.utilssqlalchemy import json_resp

    blueprint = Blueprint(__name__)

    @blueprint.route('/myview')
    @json_resp
    def my_view():
        return {'result': 'OK'}


    @blueprint.route('/myerrview')
    @json_resp
    def my_err_view():
        return {'result': 'Not OK'}, 400






Authentification avec pypnusershub
==================================


Vérification des droits des utilisateurs
----------------------------------------


pypnusershub.routes.check_auth
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Décorateur pour les routes : vérifie les droits de l'utilisateur et le redirige en cas de niveau insuffisant ou d'informations de session erronés
(deprecated) Privilegier `check_auth_cruved`

params :

* level <int>: niveau de droits requis pour accéder à la vue
* get_role <bool:False>: si True, ajoute l'id utilisateur aux kwargs de la vue
* redirect_on_expiration <str:None> : identifiant de vue  sur laquelle rediriger l'utilisateur en cas d'expiration de sa session
* redirect_on_invalid_token <str:None> : identifiant de vue sur laquelle rediriger l'utilisateur en cas d'informations de session invalides


    ::

    from flask import Blueprint
    from pypnusershub.routes import check_auth
    from geonature.utils.utilssqlalchemy import json_resp

    blueprint = Blueprint(__name__)

    @blueprint.route('/myview')
    @check_auth(
        1,
        True,
        redirect_on_expiration='my_reconnexion_handler',
        redirect_on_invalid_token='my_affreux_pirate_handler'
        )
    @json_resp
    def my_view(id_role):
        return {'result': 'id_role = {}'.format(id_role)}



pypnusershub.routes.check_auth_cruved
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Décorateur pour les routes : Vérifie les droits de l'utilisateur à effectuer une action sur la donnée et le redirige en cas de niveau insuffisant ou d'informations de session erronées

params :

* action <str:['C','R','U','V','E','D']> type d'action effectuée par la route (Create, Read, Update, Validate, Export, Delete)
* get_role <bool:False>: si True, ajoute l'id utilisateur aux kwargs de la vue
* redirect_on_expiration <str:None> : identifiant de vue  sur laquelle rediriger l'utilisateur en cas d'expiration de sa session
* redirect_on_invalid_token <str:None> : identifiant de vue sur laquelle rediriger l'utilisateur en cas d'informations de session invalides


    ::

    from flask import Blueprint
    from pypnusershub.routes import check_auth_cruved
    from geonature.utils.utilssqlalchemy import json_resp

    blueprint = Blueprint(__name__)

    @blueprint.route('/mysensibleview', methods=['GET'])
    @check_auth_cruved(
        'R',
        True,
        redirect_on_expiration='my_reconnexion_handler',
        redirect_on_invalid_token='my_affreux_pirate_handler'
        )
    @json_resp
    def my_sensible_view(id_role):
        return {'result': 'id_role = {}'.format(id_role)}

