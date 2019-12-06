// Get a reference to the database service
var database = firebase.database();

var orders = [];

var dbRef = firebase.database().ref('Orders');
var startListening = async function () {
    await dbRef.on('value', function (snapshot) {
        // loadItemsFromFirebase();
        console.log(snapshot);
        orders = [];
        snapshot.forEach(function (child) {
            console.log(child.key, child.val());
            if (child.val().status == "done") {
                orders.push(child.val());
            }

            orders.sort(function (a, b) {
                return parseFloat(a.id) - parseFloat(b.id);
            });
        });
        populateTable();
    });

}

$(document).ready(function () {
    startListening();
});


function populateTable() {

    $("#orderTable").empty();

    var table = document.getElementById('orderTable');
    var tHead = document.createElement('thead');
    var a = document.createElement('th');
    var b = document.createElement('th');
    var c = document.createElement('th');

    a.innerText = "#";
    b.innerText = "Order";
    c.innerText = "Action";

    tHead.appendChild(a);
    tHead.appendChild(b);
    tHead.appendChild(c);

    table.appendChild(tHead);

    var tBody = document.createElement('tbody');


    orders.forEach((order) => {
        var row = document.createElement('tr');

        var orderNum = document.createElement("td");
        var orderText = document.createElement("td");
        var orderStatus = document.createElement("td");
        var button = document.createElement("button");

        button.innerText = "Picked Up!";
        button.classList.add("btn");
        button.classList.add("btn-success");
        button.classList.add("btn-rounded");
        button.classList.add("float-none");
        button.classList.add("btn-sm");
        button.classList.add("my-0");
        button.classList.add("mr-2");
        button.addEventListener("click", startPreparing);
        button.id = "order" + order.id;

        orderNum.innerHTML = order.id;
        orderText.innerHTML = order.order;
        orderStatus.appendChild(button);
        row.appendChild(orderNum);
        row.appendChild(orderText);
        row.appendChild(orderStatus);
        tBody.appendChild(row);
    });

    table.appendChild(tBody);

}

function startPreparing() {
    console.log("Removing " + this.id + "from database");

    let orderRef = firebase.database().ref('Orders');
    orderRef.child(this.id).child('status').transaction(function (status) {
        if (status) {
            status = 'picked';
        }

        return status;

    });

}
