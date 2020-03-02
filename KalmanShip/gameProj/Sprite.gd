extends Sprite

var speed = 10
var newPos = Vector2(0,0)
var curPos = Vector2(0,0)
var angle = 0
var commClient
var commServer
var kalman = Vector2(0,0)

func _ready():
	curPos = get_offset()
	print(curPos)
	commClient = PacketPeerUDP.new()
	commClient.set_dest_address("127.0.0.1",4243)
	commServer = PacketPeerUDP.new()
	commServer.set_dest_address("127.0.0.1",4244)
	if(commServer.listen(4244,"127.0.0.1") != OK):
		print("an error occurred listening on port " + str(4244))
	else:
		print("Listening on port " + str(4244) + " on " + "127.0.0.1")
	
func _peer_connected(id):
	var text = "\nUser " + str(id) + " connected"
	var userText = "Total Users:" + str(get_tree().get_network_connected_peers().size())
	print(text)
	print(userText)
  
func _peer_disconnected(id):
	var text = "\nUser " + str(id) + " connected"
	var userText = "Total Users:" + str(get_tree().get_network_connected_peers().size())
	print(text)
	print(userText)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	curPos = get_offset()
	receiveCorrection()
	newPos.x = curPos.x + speed + kalman.x
	newPos.y = curPos.y + 0.2 + kalman.y
	var slope = (newPos.y-curPos.y)/(newPos.x-curPos.x)
	angle = tan(slope)
	rotate(deg2rad(angle))
	set_offset(newPos)
	sendMeasurement()

func plot():
	pass
	
func sendMeasurement():
	var separator = ":"
	var text = "$MEAS"+ separator + String(newPos.x) + separator + String(newPos.y) + separator + String(angle) 
	commClient.put_packet(text.to_ascii())
	
	
func receiveCorrection():
	kalman = Vector2(0,0)
	if(commServer.get_available_packet_count() > 0):
		var recvMsg = commServer.get_packet().get_string_from_ascii ()
		var textArray = recvMsg.split(":",true)
		if(textArray[0] == String("$KALMAN1")):
			kalman = Vector2(float(textArray[1]),float(textArray[2]))
		
	

