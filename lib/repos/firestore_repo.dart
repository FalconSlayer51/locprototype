import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';

class FireStoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final geo = GeoFlutterFire();

  Stream<List<DocumentSnapshot>> getMarkers(Position position)  {
    final center =
        geo.point(latitude: position.latitude, longitude: position.longitude);
    const radius = 100.0;
    final collectionRef = _firestore.collection('users');
    return  geo.collection(collectionRef: collectionRef).within(
          center: center,
          radius: radius,
          field: 'position',
          strictMode: true,
        );
  }
}
