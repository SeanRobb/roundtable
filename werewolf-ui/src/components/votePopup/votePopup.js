import React from 'react';
import PropTypes from 'prop-types';
import styles from './votePopup.module.css';
import {Dialog, DialogTitle, Box, Button, Grid} from '@material-ui/core';

const VotePopup = (props) => (
  <Dialog data-testid="votePopup"
    open={props.open}
    onClose={props.onClose}
    className={styles.VotePopup} 
  >
  <Grid container direction='column' justify='center' alignItems='stretch'>
    <Grid item>
      <DialogTitle>
        Ballot
      </DialogTitle>
    </Grid>
    {props.ballot?props.ballot
      .map((person) =>
      <Grid item key={person}>
        <Button 
          variant="contained" color="primary"
            style={{margin:'10px'}} size="large" onClick={()=>props.onVote(person)}>
          {person}
        </Button>
      </Grid>
        ):''}
  </Grid>
</Dialog>
);

VotePopup.propTypes = {};

VotePopup.defaultProps = {};

export default VotePopup;
