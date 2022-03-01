import React from 'react';

class RuleFields extends React.Component {
  constructor(props) {
    super(props);
    this.state = { operation: this.props.action_operation };
    /* XXX Why can't we use ES6 fat-arrow for this? Gem too old? */
    this.operationSelected = this.operationSelected.bind(this);
  }

  operationSelected(e) {
    this.setState({
      operation: e.target.value
    });
  }

  options(operation) {
    return this.props.actions[operation].values.map((user) => {
      return <option key={user.key} value={user.key}>{user.value}</option>
    });
  }

  render () {
    let action_value = <select className="form-control" name="rule[action_value]"
            value={this.props.action_value}>
      {this.options(this.state.operation)}
    </select>;

    let actions = [];
    for(let key in this.props.actions) {
      actions.push(<option key={key} value={key}>{this.props.actions[key].label}</option>);
    }

    return (
      <div className="input-group">
        <div class="input-group-prepend">
          <label className="input-group-text" htmlFor="rule[action_operation]">{this.props.label_action_operation}</label>
        </div>
        <select className="form-control" onChange={this.operationSelected}
            name="rule[action_operation]"
            value={this.state.operation}>
          {actions}
        </select>
        <div class="input-group-prepend">
          <label className="input-group-text border-left-0" htmlFor="rule[action_value]">
            {this.props.actions[this.state.operation].label}
          </label>
        </div>
        {action_value}
      </div>
    );
  }
}

export default RuleFields;
